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
 $errs = Multi::WaitForCommandsToComplete(\&Multi::RunNext);
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
our $PIDTAG = 1;

#==================================================================
# Subroutine:
#   RunCommand
#==================================================================

=head1 NAME

 #=============================================
 #  RunCommand ( cmd, tag )
 #=============================================

=head1 SYNOPSIS

 $cmd = 'merlin -d a.dat -p a.ped -m a.map --fastAssoc';
 Multi::RunCommand($cmd);
 Multi::RunCommand($cmd, 'a');

=head1 DESCRIPTION

Use this to issue a Unix command in a child process.
You'll probably want to use B<WaitForCommandsToComplete();> later in your code.
This sets %PIDS with details about the process that is running.

The B<tag> is a simple scalar which will be passed to the function
you provide to B<CommandComplete()>.

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

=item B<tag>

A simple scalar that is passed to WaitForCommandsToComplete which could
be used to do something more complex than just run the next command.

=back

=cut

sub RunCommand {
    my ($cmd, $tag) = @_;
    if (! defined($tag)) { $tag = ''; }
    if ($PAUSE) { sleep $PAUSE; }           # Avoid submitting too fast
    if ($cmd =~ /\s+&\s*\"?$/) {            # " Commands may not have fork in them
        if ($VERBOSE) { warn "Removing fork meta character from cmd: $cmd\n"; }
        $cmd =~ s/\s+&\s*\"?$/\"/g;
    }
    my $p;
    if ($p = fork) {
        $PIDS{$p}[$PIDCMD] = $cmd;          # Remember stuff about child command
        $PIDS{$p}[$PIDTAG] = $tag;
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
 Multi::QueueCommands($cmds, 2);            # Run three at a time
 Multi::WaitForCommandsToComplete(\@cmds);

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
 #  WaitForCommandsToComplete( \&callbackref )
 #=============================================

=head1 SYNOPSIS

 n = Multi::WaitForCommandsToComplete(\&Multi::RunNext);

=head1 DESCRIPTION

This routine waits for a child process to complete and then
calls the callback routine (e.g. RunNext) to launch the next.
When all commands have been run, the routine returns
with the count of processes that ended with a non-zero return code.

=head1 PARAMETERS

=over 4

=item B<rtn>

This is the address of a function to be called when each child ends.

=back

=cut

sub WaitForCommandsToComplete {
    my ($callbackref) = @_;
    my $errs = 0;
    while (%PIDS) {
        my $p = waitpid(-1, 0);                 # Wait for child to terminate
        if ((! defined($p)) || $p < 0) { next; }
        my $rc = $? >> 8;
        if ($rc) { $errs++; }
        if ($VERBOSE) {
            my $st = 'completed';
            if ($rc) { $st = 'failed  '; }
            warn "Process $p $st RC=${rc}: CMD=$PIDS{$p}[$PIDCMD]\n";
        }
        #   If a callback was provided, call user routine. This sets %PIDS
        #   The callback is typically RunNext
        if (defined($callbackref)) {
            $callbackref->($PIDS{$p}[$PIDTAG]);
        }
        undef($PIDS{$p});                       #
        delete($PIDS{$p});                      # No longer interested in this
    }
    return $errs;
}

#==================================================================
# Subroutine:
#   RunNext
#==================================================================

=head1 NAME

 #=============================================
 #  RunNext( tag )
 #=============================================


=head1 SYNOPSIS

 Multi::RunNext( \%keeptrack );

=head1 DESCRIPTION

Launches a command in a new process.  Sets %PIDS so other code can keep
track of the process.

=head1 PARAMETERS

=over 4

=item B<tag>

Specifies a tag passed to a user-cloned version of this code which
might manage something else as each command completes.

=back

=cut

sub RunNext {
    my ($tag) = @_;
    if (! defined($tag)) { $tag = ''; }

    #   Pick next command to run
    for ( ;$NEXTCMD<=$#COMMANDS; $NEXTCMD++) {
        if ($COMMANDS[$NEXTCMD] !~ /^\s*#/) { last; }
    }
    if ($NEXTCMD > $#COMMANDS) { return; }  # No more to run
    RunCommand($COMMANDS[$NEXTCMD], $tag);
    $NEXTCMD++;                             # Look here next
}

#==================================================================
#   Perldoc Documentation
#==================================================================
1;                                  # So Perl require is happy
__END__

=head1 AUTHOR

This was written by Mary Kate Wing I<E<lt>mktrost@umich.eduE<gt>> in 2013.
This code is made available under terms of the GNU General Public License.

=cut
