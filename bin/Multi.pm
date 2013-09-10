###################################################################
#
# Name: Multi.pm
#
# ChangeLog:
#   $Log: Multi.pm,v $
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
###################################################################

=head1 NAME

Multi.pm

=head1 SYNOPSIS

 use Multi;
 my @cmds = ('sleep 10', 'sleep 8', 'sleep 6', 'sleep 4', 'sleep 2',
  'ls /tmp', 'lxs -la /usr', 'head /etc/rc.xlocal', 'sleep 5', 'sleep 3');
 $Multi::VERBOSE = 1;
 Multi::QueueCommands(\@cmds, 3);    # Run three at a time
 $errs = Multi::WaitForCommandsToComplete();
 warn "$errs commands failed\n";

=head1 DESCRIPTION

Use the functions in this package to help manage running concurrent jobs.

=cut

package Multi;

use strict;
use vars qw($VERSION $VERBOSE $PAUSE );

$VERSION = sprintf("%d.%02d", q$Revision: 1.7 $ =~ /(\d+)\.(\d+)/);
our $PAUSE;                             # Wait a little to submit task
our $VERBOSE;                           # Get extra messages if set
our %PIDS;                              # Keep track of what is running
our @COMMANDS;                          # Save array of commands to run here
our $NEXTCMD;                           # Index into @COMMANDS
our $PIDCMD = 0;                        # Index in %PIDS{key} array
our $WAITORNOT = '';                    # Wait for cmds or not ($ClusterTypes{engine}[0])

#   Define known types of clusters.  Array is command to queue with and extra options to use
#   First field indicates if the command will run to completion (wait)
#   or not (n)
#   Second field is the command to use to run the command
#   Third  field are options for the second field
#   Fourth field is cmd user uses to see if cmds have completed
our %ClusterTypes = (
    # name     wait?  command     opts for command   status command
    sgei     => ['w', 'qrsh',     '-now n',          ''],
    sge      => ['n', 'qsub',     '',                "qstat -u $ENV{USER}"],
    mosix    => ['w', 'mosbatch', '-E/tmp',          ''],
    mosbatch => ['w', 'mosbatch', '-E/tmp',          ''],
    slurm    => ['n', 'sbatch',   '',                "squeue -u $ENV{USER}"],
    slurmi   => ['w', 'srun',     '',                ''],
    pbs      => ['n', 'qsub',     '',                "qstat -u $ENV{USER}"],
    flux     => ['n', 'qsub',     '',                "qstat -u $ENV{USER}"],
    local    => ['w', '',         '',                ''],
);
our $BASHNAME = 'tmp_cluster_remove_whendone';  # When we create a script to be run
our $BASHDIR = '.';                     # Create BASHNAME scripts here

#==================================================================
# Subroutine:
#   EngineDetails
#==================================================================

=head1 NAME

 #=============================================
 #  $href = EngineDetails ( engine )
 #=============================================

=head1 SYNOPSIS

 $href = Multi::EngineDetails('slurm');
 print "Wait to complete: " . $href->{wait} . "\n";
 print "Submitted by: " . $href->{cmd} . "\n";
 print "Forced options: " . $href->{opts} . "\n";
 print "Status command is: " . $href->{status} . "\n";

=head1 DESCRIPTION

Use this to obtain attributes of the cluster engine to be used.
This returns a reference to a hash of possibly useful information.

=head1 PARAMETERS

=over 4

=item B<engine>

Specifies the type of cluster to submit the jobs to.
If engine is not defined or null, it defaults to 'local'.
Valid values can be found in ClusterTypes at the top of this code.

=back

=cut

sub EngineDetails {
    my ($engine) = @_;
    my %details = ();
    if ((! defined($engine)) || $engine eq '') { $engine = 'local'; }
    if (exists($ClusterTypes{$engine})) {
        $details{wait} = $ClusterTypes{$engine}[0];
        $details{cmd} = $ClusterTypes{$engine}[1];
        $details{opts} = $ClusterTypes{$engine}[2];
        $details{status} = $ClusterTypes{$engine}[3];
    }
    return \%details;
}

#==================================================================
# Subroutine:
#   RunCommand
#==================================================================

=head1 NAME

 #=============================================
 #  RunCommand ( cmd )
 #=============================================

=head1 SYNOPSIS

 $cmd = 'merlin -d a.dat -p a.ped -m a.map --fastAssoc';
 Multi::RunCommand($cmd);

=head1 DESCRIPTION

Use this to issue a Unix command in a child process.
You'll probably want to use B<WaitForCommandsToComplete();> later in your code.
This sets %PIDS with details about the process that is running.

This function returns nothing. If the command cannot be launched
the command fails with a B<die> message.
When issuing the command, this routine may pause a short time ($Multi::PAUSE)
in order to avoid swamping the system with tasks.

Calling this function is not quite the same as B<system('sleep 10 &');>
because the latter does not save the process id, so you cannot
wait for a specific child to complete without a lot of work.

=head1 PARAMETERS

=over 4

=item B<cmd>

A command to run. Any '&' are removed.

=back

=cut

sub RunCommand {
    my ($cmd) = @_;
    if ($PAUSE) { sleep $PAUSE; }           # Avoid submitting too fast
    if ($cmd =~ /\s+&\s*\"?$/) {            # " Commands may not have fork in them
        if ($VERBOSE) { warn "Removing fork meta character from cmd: $cmd\n"; }
        $cmd =~ s/\s+&\s*\"?$/\"/g;
    }
    my $p;
    if ($p = fork) {
        $PIDS{$p}[$PIDCMD] = $cmd;          # Remember stuff about child command
        return;
    }
    if (defined($p)) {                      # Child code here
        if ($VERBOSE) { warn "Process $$ starting cmd: $cmd\n"; }
        exec($cmd);                         # Reuses my process space
        die "Unable to execute command: $cmd\n";    # Should never get here
    }
    die "Unable to fork: $!\n";             # Should never get here
}

#==================================================================
# Subroutine:
#   QueueCommands
#==================================================================

=head1 NAME

 #=============================================
 #  QueueCommands( \@cmdlistref, maxconcurrent )
 #=============================================

=head1 SYNOPSIS

 @cmds = ('merlin -d a.dat -p a.ped -m a.map --fastAssoc',
    'merlin -d b.dat -p b.ped -m b.map --fastAssoc',
    'merlin -d c.dat -p c.ped -m c.map --fastAssoc',
    'merlin -d d.dat -p d.ped -m d.map --fastAssoc',
    'merlin -d e.dat -p e.ped -m e.map --fastAssoc');
 Multi::QueueCommands($cmds, 2);            # Run two at a time
 Multi::WaitForCommandsToComplete();

=head1 DESCRIPTION

Queue an array of commands to execute and begins running the
first set (maxconcurrent).

=head1 PARAMETERS

=over 4

=item B<cmdlistref>

This is a reference to an array of commands to run.

=item B<maxconcurrent>

Specifies the number of commands to run concurrently.
This defaults to '1'.

=back

=cut

sub QueueCommands {
    my ($cmdlistref, $maxconcurrent) = @_;
    if (! defined($maxconcurrent)) { $maxconcurrent = 1; }
    @COMMANDS = @{$cmdlistref};             # Copy commands to avoid problems

    #   Prime queue by getting some set of commands running
    for (1 .. $maxconcurrent) {
        my $c = shift @COMMANDS;
        if ($c) { RunCommand($c); }
    }
    $NEXTCMD = 0;
    return;
}

#==================================================================
# Subroutine:
#   WaitForCommandsToComplete
#==================================================================

=head1 NAME

 #=============================================
 #  WaitForCommandsToComplete()
 #=============================================

=head1 SYNOPSIS

 n = Multi::WaitForCommandsToComplete();

=head1 DESCRIPTION

This routine waits for a child process to complete and then
calls the callback routine, RunNext, to launch the next.
When all commands have been run, the routine returns
with the count of processes that ended with a non-zero return code.

=cut

sub WaitForCommandsToComplete {
    my $errs = 0;
    while (%PIDS) {
        my $p = waitpid(-1, 0);                 # Wait for child to terminate
        if ((! defined($p)) || $p < 0) { next; }
        my $rc = $? >> 8;
        if ($rc) { $errs++; }
        if ($VERBOSE) {
            if ($rc) { warn "Process $p failed  RC=${rc}: CMD=$PIDS{$p}[$PIDCMD]\n"; }
            else {
                print STDERR "Process $p completed";
                if ($WAITORNOT eq 'n') {
                    print STDERR ", but task not finished. " .
                        "Use other commands to watch for completion";
                }
                print STDERR "\n";
            }
        }
        #   If the command was one we made up for interactive tasks, remove it
        if ($PIDS{$p}[$PIDCMD] =~ /\s(\S+$BASHNAME\S+~w\S+)/) {
            my $f = $1;
            unlink($f);
            if ($VERBOSE) { warn "Removed script '$f'\n"; }
        }
        undef($PIDS{$p});
        delete($PIDS{$p});                      # No longer interested in this
        #   Launch the next command to run
        if ($NEXTCMD <= $#COMMANDS) {
            RunCommand($COMMANDS[$NEXTCMD]);
            $NEXTCMD++;
        }
    }
    return $errs;
}

#==================================================================
# Subroutine:
#   RunCluster
#==================================================================

=head1 NAME

 #=============================================
 #  RunCluster( engine, opts, cmdsaref, maxconcurrent, bashdir )
 #=============================================


=head1 SYNOPSIS

 $boolean = Multi::RunCluster( 'slurmi', $engine_opts, \@cmds, maxconcurrent, bashdir );

=head1 DESCRIPTION

Runs an array of commands 'acmdsref' on a cluster of type 'engine'.
The queuing command is passed the options 'opts'.
This function returns a boolean if the commands were submitted without error.
Warnings are issued detailing problems.
This returns a nonzero if anything was in error.

=head1 PARAMETERS

=over 4

=item B<engine>

Specifies the type of cluster to submit the jobs to.
If engine is not defined or null, it defaults to 'local'.
Valid values can be found in ClusterTypes at the top of this code.

=item B<opts>

When a job is submitted the command will be passed these options.

=item B<cmdsaref>

Is a reference to an array of commands to be submitted to the cluster.
These should not have an ampersand at the end of the line.

=item B<maxconcurrent>

Specifies the number of commands to run concurrently.
This defaults to '1'.

=item B<bashdir>

When a shell script must be created to submit a command, create it
in this directory.
This defaults to the current working directory.
Be careful this path can also resolve properly when the command runs on another host.

=back

=cut

sub RunCluster {
    my ($engine, $opts, $cmdsaref, $maxconcurrent, $bashdir) = @_;
    if ((! defined($engine)) || $engine eq '') { $engine = 'local'; }
    if (! defined($opts))     { $opts = ''; }
    if (! defined($maxconcurrent)) { $maxconcurrent = 1; }
    if (! defined($bashdir))  { $bashdir = $BASHDIR; }
    if ($bashdir eq '.' || $bashdir eq '') { $_ = `pwd`; chomp($_); $bashdir = $_; }
    else { mkdir $bashdir, 0755; }                  # If necessary, create directory for jobs

    #   Pick next command to run
    if (! $ClusterTypes{$engine}) {
        warn "Cluster type '$engine' is not supported - no jobs started\n";
        return 1;
    }
    if (! $#{$cmdsaref} < 0) {
        warn "No commands were provided to submit to '$engine' - no jobs started\n";
        return 1;
    }

    #   Run through list of commands, create shell scripts as necessary
    #   If the command looks like a shell script we support, run it directly
    my $modelcmd = "$ClusterTypes{$engine}[1] $ClusterTypes{$engine}[2] $opts ";
    $WAITORNOT = $ClusterTypes{$engine}[0]; # Checked elsewhere
    my @commands = ();
    my $index = 1;
    foreach my $c (@{$cmdsaref}) {
        if ($c =~ /^\s*$/) { next; }        # Skip blank lines and comments
        if ($c =~ /^#/) { next; }
        if ($c !~ /[|;(]/) {                # Not multiple cmds or pipe
            if ($c =~ /^\s*(\S+)/) {        # Isolate pgm to run
                my $s = `/usr/bin/file $1 2>/dev/null`;
                if ($s =~ /ascii text executable/i) {   # Simple shell script
                    push @commands,$modelcmd . $c;      # can be run directly
                    next;
                }
            }
        }
        #   User provided a command, wrap it in a BASH script
        #   Bash script name contains : + n or w (wait or nowait)
        my $f = $bashdir . '/' . $BASHNAME . '_' . $index . '_' . $$ . '~' . $ClusterTypes{$engine}[0] . '.sh';
        $index++;
        open(OUT, '>' . $f) || die "Unable to create script: $f:  $!\n";
        print OUT "#!/bin/bash\nset -o pipefail\n$c\nexit \$?\n";
        close(OUT);
        chmod(0755, $f) || exit 1;
        push @commands,$modelcmd . $f;
    }
    if (! @commands) { warn "Found no commands to queue\n";  return 1; }
    QueueCommands(\@commands, $maxconcurrent);
    return WaitForCommandsToComplete();
}

#==================================================================
#   Perldoc Documentation
#==================================================================
1;                                  # So Perl require is happy
__END__

=head1 AUTHOR

This was written by Mary Kate Wing I<E<lt>mktrost@umich.eduE<gt>>
and Terry Gliedt I<E<lt>tpg@umich.eduE<gt>> in 2013.
This code is made available under terms of the GNU General Public License.

=cut
