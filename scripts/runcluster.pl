#!/usr/bin/env perl
#################################################################
#
# Name: runcluster.pl [-v] engine_type cmd1 cmd2 ...
#
# Description:
#   Use this to submit a command to the cluster engines
#
# ChangeLog:
#   29 Nov 2012 tpg   Initial coding
#   04 Feb 2013 tpg   Add support for slurm and mosix
#   11 Feb 2013 tpg   Add PBS support
#   30 Mar 2014 tpg   Wait for SLURM batch jobs to complete
#    5 Apr 2014 tpg   Wait for SGE and PBS batch jobs to complete
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd;
use Cwd 'abs_path';

my ($me, $mepath, $mesuffix) = fileparse($0, '\.pl');
(my $version = '$Revision: 1.5 $ ') =~ tr/[0-9].//cd;

#   Define known types of clusters.  Array is command to queue with and extra options to use
#   First field indicates if the command runs to completion (i, interactive) or batch (b)
#   Batch runs are forced to run to completion by creating shell script to run the command.
#   Second field is the command to use to run the command
#   Third  field are options for the second field
#   Fourth field is cmd user uses to see if cmds have completed
my %ClusterTypes = (
    # name     wait?  command     opts for command   status command
    sgei     => ['i', 'qrsh',     '-now n',          ''],
    sge      => ['b', 'qsub',     '',                "qstat -u $ENV{USER}"],
    mosbatch => ['i', 'mosbatch', '-E/tmp',          ''],
    slurm    => ['b', 'sbatch',   '',                "squeue -u $ENV{USER}"],
    slurmi   => ['i', 'srun',     '',                "squeue -u $ENV{USER}"],
    pbs      => ['b', 'qsub',     '',                "qstat -u $ENV{USER}"],
    local    => ['i', '',         '',                ''],
);

my %opts = (
    bashdir => '.',
    autorm_ending => '~autorm.sh',
    opts => '',
    engine => 'local',
    jobname => 'GC',
    log => '',
    logfile => '',
    logkey => 'no_key',
    modelfile => "$me.model",
    waitinterval => 10,                 # Check for ok/err files really often
    waittries => 18,                    # Check for file this many times
    maxwaittries => 72,                 # Do not let $waittries grow past this
    verbose => 0,
);
Getopt::Long::GetOptions( \%opts,qw(
    help
    verbose
    jobname=s
    engine=s
    log=s
    modelfile=s
    bashdir=s
    opts=s
)) || die "Failed to parse options\n";

#   Simple help if requested, sanity check input options
if ($opts{help} || $#ARGV < 1) {
    warn "$me$mesuffix [options] type command\n" .
        "Version $version\n" .
        "Use this to run a command for GotCloud in your local cluster.\n" .
        "This is typically called by Perl scripts in GotCloud\n" .
        "Valid engine_types are: " .
        ' ' . join(' ', sort keys %ClusterTypes) . "\n";
    warn "This program is typically called by Perl scripts in GotCloud\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}
$opts{engine} = shift(@ARGV);
my $cmd = join(' ', @ARGV);

if ($opts{engine} eq 'flux') { $opts{engine} = 'pbs'; }     # Set up aliases
if ($opts{engine} eq 'mosix') { $opts{engine} = 'mosbatch'; }
if ($opts{log} && $opts{log} =~ /(\S+),(.+)/) {             # Set up logfile and key
    $opts{logfile} = $1;
    $opts{logkey} = $2;
}
if (! exists($ClusterTypes{$opts{engine}})) {
    die "Cluster type '$opts{engine}' is not supported - no jobs started\n";
}
if (! $cmd) {
    die "No command was provided to submit to '$opts{engine}' - no jobs started\n";
}

#   Hidden hook to get details for this engine type
if ($cmd eq 'runcluster-show-details') {
    print "Name=$opts{engine}  Type=$ClusterTypes{$opts{engine}}[0] " .
        "Cmd=$ClusterTypes{$opts{engine}}[1] " .
        "Opts=$ClusterTypes{$opts{engine}}[2] Status=$ClusterTypes{$opts{engine}}[3]\n";
    exit;
}

if ($opts{bashdir} eq '.') { $opts{bashdir} = getcwd(); }
else { mkdir $opts{bashdir}, 0755; }            # If necessary, create directory for jobs
$opts{jobname} .= $ClusterTypes{$opts{engine}}[0];      # Append i or b to jobname


#   Check the path to the cwd will be visible in the batch environment
if ($opts{engine} =~ /^mos/) {
    if (FixCWD()) {
        if ($opts{verbose}) { warn "Current working directory set to '" . getcwd() . "'\n"; }
    }
}

#   Interactive jobs are easier, just build command and execute it
if ($ClusterTypes{$opts{engine}}[0] eq 'i') {
    my $runcmd = icommand("$ClusterTypes{$opts{engine}}[1] $ClusterTypes{$opts{engine}}[2] $opts{opts}", $cmd);
    if (! $runcmd) {
        die "Unable to create commands to submit to '$opts{engine}' - no jobs started\n";
    }
    #   Run the command, remove any shell scripts we created, exit with correct return code
    if ($opts{verbose}) { warn "Executing interactive job '$opts{engine}' cmd: $runcmd\n"; }
    #   Avoid possible race condition for MOSIX :-(
    #if ($opts{engine} =~ /^mos/) { sleep(1); warn "waiting\n"; }
    my $rc = system($runcmd) >> 8;
    if ((! $opts{verbose}) && $runcmd =~ /\s+(\S+$opts{autorm_ending})/) { unlink $1; }  # Delete shell we created
    exit($rc);

}

#   Batch jobs are more complex.  Submit the job and wait for it to complete
if ($ClusterTypes{$opts{engine}}[0] eq 'b') {
    my $runshell;
    my $runcmd = bcommand("$ClusterTypes{$opts{engine}}[1] $ClusterTypes{$opts{engine}}[2] $opts{opts}", $cmd);
    if (! $runcmd) {
        die "Unable to create commands to submit to '$opts{engine}' - no jobs started\n";
    }
    if ($runcmd =~ /\s+(\S+$opts{autorm_ending})/) { $runshell = $1; }  # Script we are running

    #   Run the command, catch the job-id and then wait for it complete
    if ($opts{verbose}) { warn "Executing batch job '$opts{engine}' cmd: $runcmd\n"; }
    my $f = "/tmp/$$.batchlog";
    my $rc = system("$runcmd > $f") >> 8;
    if ($rc) {                              # Unable to submit job
        system("cat $f");
        unlink($f);
        exit($rc);
    }
    my $submitline = '';
    if (open(IN,$f)) {                      # Get job-id from submit command output
        $submitline = <IN>;
        chomp($submitline);
        close(IN);
    }
    unlink($f);
    #   Wait for batch job to complete
    if ($runshell) {
        $rc = waitforcommand($runshell, $submitline, $opts{engine});
    }
    if ((! $opts{verbose}) && $runshell) { unlink $runshell; }      # Delete shell we created
    exit($rc);
}

#==================================================================
# Subroutine:
#   FixCWD()
#
#   Correct the path to the cwd so it will be visible in the batch environment
#   Path does not start with net, problems in cluster
#   Watch out for local surprise, /home/xyz might be /exports/home/xyz
#
#   Returns:  boolean if CD was done
#==================================================================
# TODO - we should make this a configurable option not hard-coded based on our system
sub FixCWD {
    # my ($a, $b) = @_;
    my $abs_path = abs_path('.');
    if ($abs_path =~ /\/net/) { return 0; }
    $abs_path =~ s/^\/exports//;                # Local network screw-up
    my $host = `hostname`;
    chomp($host);
    my $cwd = "/net/$host" . $abs_path;
    chdir($cwd) && return 1;
    warn "Unable to CD to '$cwd' to correct local networking anomaly\n";
    return 0;
}

#==================================================================
# Subroutine:
#   $cmd = icommand($prefixcmd, $cmd)
#
#   Returns an interactive command to be run. This might simply
#   be the original command prefixed by some simple command
#   or it might be the command is run in a shell script
#   so that pipe failures can be caught.
#
#   Returns:  command to execute
#==================================================================
sub icommand {
    my ($prefixcmd, $cmd) = @_;

    #   If the command looks like a shell script we support, run it directly
    #   If not multiple cmds or pipe, maybe we can run it directly
    if ($cmd !~ /[|;(]/) {
        if ($cmd =~ /^\s*(\S+)/) {        # Isolate pgm to run
            my $s = `/usr/bin/file $1 2>/dev/null`;
            if ($s =~ /ascii text executable/i) {   # Simple shell script
                return $prefixcmd . ' ' . $cmd;
            }
        }
    }
    #   This command must be wrapped in a BASH script
    my $f = $opts{bashdir} . '/' . $opts{jobname} . '_' . $$ . $opts{autorm_ending};
    open(OUT, '>' . $f) || die "icommand: Unable to create script: $f:  $!\n";
    print OUT "#!/bin/bash\nset -o pipefail\n";
    if ($opts{logfile}) {
        print OUT "$mepath/gclogger.pl $opts{logkey} $opts{logfile} RUNSTART\n";
    }
    print OUT $cmd . "\nrc=\$?\n";
    if ($opts{logfile}) {
        print OUT "$mepath/gclogger.pl $opts{logkey} $opts{logfile} RUNSTOP rc=\$rc\n";
    }
    print OUT "exit \$rc\n";
    close(OUT);
    if ($opts{verbose}) { warn "Created shell script '$f' to run command\n"; }
    chmod(0755, $f) || exit 1;
    return $prefixcmd . ' ' . $f;
}

#==================================================================
# Subroutine:
#   $cmd = bcommand($prefixcmd, $cmd)
#
#   Returns a batch command to be run in the form of a script
#   which actually submits the script to the engine
#   When the command completes, it will touch a file (error or ok)
#   which can be detected by waitforcommand()
#
#   Returns:  command to execute
#==================================================================
sub bcommand {
    my ($prefixcmd, $cmd) = @_;

    my $f = $opts{bashdir} . '/' . $opts{jobname} . '_' . $$ . $opts{autorm_ending};
    open(OUT, '>' . $f) ||
        die "Unable to create file '$f': $!\n";
    my $ff = $opts{modelfile};
    if (! -r $ff) { $ff = $ENV{HOME} . '/' . $opts{modelfile}; }
    if (! -r $ff) { $ff = $mepath . '/' . $opts{modelfile}; }
    open(IN, $ff) ||
        die "Unable to open file '$ff': $!\n";

    my $logStart = '';
    my $logEnd = '';
    if ($opts{logfile})
    {
        $logStart = "$mepath/gclogger.pl $opts{logkey} $opts{logfile} RUNSTART";
        $logEnd = "$mepath/gclogger.pl $opts{logkey} $opts{logfile} RUNSTOP rc=\$rc";
    }

    while (<IN>) {
        if (/^#%(\S+)/) {                   # Yes substitution
            my $key = $1;
            if ($key eq 'OPTIONS') {        # Look for engine.options in HOME or cwd
                my $ff = $opts{engine} . '.options';
                if (! -r $ff) { $ff = $ENV{HOME} . '/' . $opts{engine} . '.options'; }
                if (open(INOPTIONS, $ff)) {
                    my @l = <INOPTIONS>;
                    print OUT @l;
                    close(INOPTIONS);
                }
                next;
            }
            if ($key eq 'JOBNAME') {        # Set jobname variable
                print OUT "jname='$opts{jobname}.$$'\n";
                next;
            }
            if ($key eq 'VERBOSE') {        # Set jobname variable
                print OUT "verbose='$opts{verbose}'\n";
                next;
            }
            if ($key eq 'COMMAND') {        # Here is command to run
                print OUT "$cmd\n";
                next;
            }
            if ($key eq 'BASETOUCHFILE') {        # Here is path to shell we created
                print OUT "basefile=$f\n";
                next;
            }
            if ($key eq 'LOGSTART') {
                print OUT "$logStart\n";
                next;
            }
            if ($key eq 'LOGEND') {
                print OUT "$logEnd\n";
                next;
            }
        }
        print OUT $_;
    }
    close(IN);
    close(OUT);
    if ($opts{verbose}) { warn "Created shell script '$f' to run command\n"; }
    chmod(0700, $f);
    return $prefixcmd . ' ' . $f;
}

#==================================================================
# Subroutine:
#   waitforcommand($shell, $submitline, $engine)
#
#   Wait for a Batch script to complete.
#   $submitline is the output from the batch command (e.g. sbatch)
#   From this we can extract the job-id.
#   The script we create will create an ok or err file when
#   it completes.  This is our normal way to check the job
#   has finished, but just in case the job was cancelled or
#   failed in some other way, every once in a while we must
#   query the batch system to see if the job is still running.
#
#   The ok/err files are $shell + .ok or .err and have been
#   set up in the runcluster.model shell script to run the command.
#
#   Returns:   return code of command being run
#
#==================================================================
sub waitforcommand {
    my ($shell, $submitline, $engine) = @_;

    #   Get the job-id
    my $jobid = '';
    if ($submitline =~ /Submitted batch job (\S+)/) { $jobid = $1; }    # Good for SLURM
    if ($submitline =~ /^(\d+)\./) { $jobid = $1; }         # Good for PBS
    if ($submitline =~ /job (\d+) \(/) { $jobid = $1; }     # Good for SGE
    if (! $jobid) {
        warn "Unable to determind $engine job-id. Waiting may fail. Line=$submitline\n";
        $jobid = 'lost-job-id';
    }
    #   Figure out syntax for query command. Assume SLURM, adjust for others.
    my $querycmd = $ClusterTypes{$opts{engine}}[3] . ' ' . $jobid;
    if ($engine eq 'slurm') { $querycmd = $ClusterTypes{$opts{engine}}[3] . ' -j ' . $jobid; }
    if ($engine eq 'pbs')   { $querycmd = $ClusterTypes{$opts{engine}}[3] . ' -f ' . $jobid; }
    #   The most efficient way to wait is to check for the ok/err files
    #   to appear. We try that for a while and eventually try the
    #   query for the batch system and see if the job is still there
    while (1) {
        foreach (1 .. $opts{waittries}) {
            if ($opts{verbose}) { print "Wait $_\n"; }
            sleep($opts{waitinterval});
            if (-r "$shell.err") {
                unlink("$shell.err");
                if ($opts{verbose}) { print "Found $shell.err\n"; }
                return 1;
            }
            if (-r "$shell.ok")  {
                unlink("$shell.ok");
                if ($opts{verbose}) { print "Found $shell.ok\n"; }
                return 0;
            }
        }

        #check whether the scheduler thinks that the job has completed.
        if ($opts{verbose}) { print "Trying query: $querycmd\n"; }
        my $qout = "/tmp/$$.queryoutput";
        if (system($querycmd . " 2>&1 >$qout") || (-z $qout)) {
            unlink($qout) or warn "Could not remove $qout\n";
            # Sleep one more time to give the file system time to catchup.
            sleep($opts{waitinterval});
            # Recheck for the err/ok file in case it is there now.
            if (-r "$shell.err") {
                unlink("$shell.err");
                if ($opts{verbose}) { print "Found $shell.err\n"; }
                return 1;
            }
            if (-r "$shell.ok")  {
                unlink("$shell.ok");
                if ($opts{verbose}) { print "Found $shell.ok\n"; }
                return 0;
            }
            warn "Batch job '$jobid' completed without setting $shell.ok or $shell.err - something is wrong\n";
            return 99;
        }
        #   Some systems remove q jobid from the queue when it completes
        #   some keep the entry around so we must parse the query output to
        #   guess what really happened.
        if ($engine eq 'pbs') {
            my $jobstate = '';
            if (open(WAITREAD, $qout)) {
                while (<WAITREAD>) {
                    if (/job_state = C/) { $jobstate = 'C'; last; }
                }
            }
            close(WAITREAD);
            if ($jobstate eq 'C') {
                unlink($qout) or warn "Could not remove $qout\n";
                warn "Batch job '$jobid' was cancelled\n";
                return 98;
            }
        }
        unlink($qout) or warn "Could not remove $qout\n";
        $opts{waittries} += 12;
        if ($opts{waittries} > $opts{maxwaittries}) { $opts{waittries} = $opts{maxwaittries}; }
        if ($opts{verbose}) { print "Next pass waittries=$opts{waittries}\n"; }
    }
}

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

runcluster.pl - Run a command from GotCloud on your local cluster

=head1 SYNOPSIS

  runcluster.pl local 'echo this is a command to run'
  runcluster.pl -opts "-w s03,s04 --mem 4g" slurm 'echo this is another command'
  runcluster.pl -opts "-w s03,s04 --mem 4g" mosix echo this is another command

=head1 DESCRIPTION

Use this program as part of the GotCloud applications to run commands
in your local cluster.
This script may need to be modified for your cluster environment.


=head1 OPTIONS

=over 4

=item B<-bashdir dir>

Specifies the path to a directory where this program could create
shell scripts, as necessary.
The path to this directory must be accessible to the cluster job.
This directory is created as necessary.
This defaults to the current working directory.

=item B<-help>

Generates this output.

=item B<-jobname name>

Specifies a the beginning part of shell scripts created by this program.
This defaults to 'GC'.

=item B<-log file,string>

Specifies the path to a log to append a start end end message for this command.
There is no default log file.

=item B<-modelfile file>

Specifies a model batch file to be used to create the script for
batch systems (e.g. B<-engine slurm> or B<-engine pbs>).
The default is B<runcluster.model> in the same directory as this program.

=item B<-opts str>

Specifies the options to be passed to the program used to submit
jobs to your cluster.

Note that options to PBS engines typically use a file for all
the many options required. In this case the option is of the
form B<pbsfile=somefile> where the file I<somefile> consists
of only the #PBS comment lines you would normally put in a
script to be run.
The default file for PBS is B<$HOME/pbs.options>.

Similarly, SLURM engines support its own convention.
The default file for SLURM is B<$HOME/slurm.options>.


=item B<-verbose>

Will generate additional messages about the running of this program.

=back

=head1 PARAMETERS

=over 4

=item B<engine_type>

Specifies the type of engine to submit the command to.
The list of valid engine_types can be seen with B<runcluster.pl>.

=item B<command>

Specifies the command to be run in the cluster.
This string can be specified as one quoted parameter
(e.g. 'make -j 4 -f abc/Makefile') or
a number of arguments (e.g. make -j 4 -f abc/Makefile)
which will be assembled as the command to be executed.
Avoid the use of single quotes if at all possible as it will
be easy to get confused trying to escape the quotes.

=back

=head1 EXIT

If no fatal errors are detected, the program exits with a
return code of 0. Any error will set a non-zero return code.

=head1 AUTHOR

Written by Mary Kate Trost I<E<lt>mktrost@umich.eduE<gt>>.
This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; See http://www.gnu.org/copyleft/gpl.html

=cut
