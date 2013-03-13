#!/usr/bin/perl
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
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################
use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my($me, $mepath, $mesuffix) = fileparse($0, '\.pl');
(my $version = '$Revision: 1.5 $ ') =~ tr/[0-9].//cd;

my %opts = (
    sge_cmd => 'qrsh -now n',           # Cmds for various engines
    mosix_cmd => 'mosrun -e -t -E/tmp',
    mosixbatch_cmd => 'mosbatch -E/tmp',        # For newer version of MOSIX
    slurm_cmd => 'srun ',
    pbs_cmd => 'qsub',
    sge_opts => '',                     # Default options for each engine
    mosix_opts => '',
    slurm_opts => '',
    pbs_opts => "pbsfile=$ENV{HOME}/.pbsfile",  # if provided, is pbsfile=file
    opts => '',
);
Getopt::Long::GetOptions( \%opts,qw(
    help
    verbose
    opts=s
)) || die "Failed to parse options\n";

#   Simple help if requested, sanity check input options
if ($opts{help}) {
    warn "$me$mesuffix [options] type command\n" .
        "Version $version\n" .
        "Use this to run a command for GotCloud in your local cluster.\n" .
        "This is typically called by Perl scripts in GotCloud\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}
my $engine = shift(@ARGV) || '';

if ($engine =~ /^local/) { Run_Local($engine); }
if ($engine =~ /^sge/)   { Run_Sun_Grid_Engine($engine); }
if ($engine =~ /^slurm/) { Run_SLURM_Engine($engine); }
if ($engine =~ /^mosix/) { Run_MOSIX_Engine($engine); }
if ($engine =~ /^pbs/)   { Run_PBS_Engine($engine); }

die "runcluster.pl: Unknown cluster engine type: '$engine'\n";

#==================================================================
# Subroutine:
#   Run_Local($e)
#
# Arguments:
#   e - engine name (could specify a subset of possibilities)
#   Also uses @ARGV for commands to execute
#
# Return:
#   Does not return
#
#==================================================================
sub Run_Local {
    my ($e) = @_;

    my $cmd = 'bash -c "set -o pipefail; '.join(' ', @ARGV).'"';
    if ($opts{verbose}) { print STDERR "$me$mesuffix : " . uc($e) . " command=$cmd\n"; }
    my $rc = (0xffff & system($cmd)) >> 8;
    exit($rc);
}

#==================================================================
# Subroutine:
#   Run_MOSIX_Engine($e)
#
# Arguments:
#   e - engine name (could specify a subset of possibilities)
#   Also uses @ARGV for commands to execute
#
# Return:
#   Does not return
#
#==================================================================
sub Run_MOSIX_Engine {
    my ($e) = @_;

    #   If new version of mosix, use mosbatch
    if (-x '/bin/mosbatch') { $opts{mosix_cmd} = $opts{mosixbatch_cmd}; }

    my $cmd2 = $opts{mosix_cmd} . ' ' . $opts{mosix_opts} . ' ' . $opts{opts} . ' bash -c "set -o pipefail; ' .
        join(' ', @ARGV).'"';
    if ($opts{verbose}) { print STDERR "$me$mesuffix : " . uc($e) . " command=$cmd2\n"; }
    my $rc2 = (0xffff & system($cmd2)) >> 8;

    exit($rc2);

    #   Write the command to a shell script so pipes and such do not get confused
    my $f = $ENV{HOME} . "/z$$.sh";
    open(OUT, '>' . $f) || die "Unable to create script: $f:  $!\n";
    print OUT "#!/bin/bash\nset -o pipefail\n" . join(' ', @ARGV) . "\n";
    close(OUT);
    chmod(0755, $f);

    my $cmd = $opts{mosix_cmd} . ' ' . $opts{mosix_opts} . ' ' . $opts{opts} . ' ';
    $cmd .= $f;
    if ($opts{verbose}) { print STDERR "$me$mesuffix : " . uc($e) . " command=$cmd\n"; }
    my $rc = (0xffff & system($cmd)) >> 8;
    unlink($f);
    exit($rc);
}

#==================================================================
# Subroutine:
#   Run_Sun_Grid_Engine($e)
#
# Arguments:
#   e - engine name (could specify a subset of possibilities)
#   Also uses @ARGV for commands to execute
#
# Return:
#   Does not return
#
#==================================================================
sub Run_Sun_Grid_Engine {
    my ($e) = @_;

    #   Qrsh can fail with: error: commlib error: got read error (closing "node002/shepherd_ijs/1")
    #   so we try writing the command to a shell script, minimizing the role
    #   that qrsh actually does
    #
    #   QRSH can fail with: "Your "qrsh" request could not be scheduled, try again later."
    #   so we add -'now n' to allow the command to be queued
    my $f = $ENV{HOME} . "/z$$.sh";
    open(OUT, '>' . $f) || die "Unable to create script: $f:  $!\n";
    print OUT "#!/bin/bash\nset -o pipefail\n" . join(' ', @ARGV) . "\n";
    close(OUT);
    chmod(0755, $f);
    my $cmd = $opts{sge_cmd} . ' ' . $opts{sge_opts} . ' ' . $opts{opts} . ' ';
    $cmd .= $f;
    if ($opts{verbose}) { print STDERR "$me$mesuffix : " . uc($e) . " command=$cmd\n"; }
    my $rc = (0xffff & system($cmd)) >> 8;
    unlink($f);
    exit($rc);
}

#==================================================================
# Subroutine:
#   Run_PBS_Engine($e)
#
# Arguments:
#   e - engine name (could specify a subset of possibilities)
#   Also uses @ARGV for commands to execute
#
# Return:
#   Does not return
#
#==================================================================
sub Run_PBS_Engine {
    my ($e) = @_;

    #   Added to support UMich FLUX cluster
    #   This is SGE and some scheduling glue which uses comments
    #   in the shell script being run.
    #   Options to PBS would be very difficult if we used conventional
    #   dash flags. Instead we'll expect to see pbsfile=pathtofile
    #   and we expect this pbsfile to be the comments in the script
    #   that will be built to run your command.
    my $f = $ENV{HOME} . "/z$$.sh";
    open(OUT, '>' . $f) || die "Unable to create script: $f:  $!\n";
    print OUT "#!/bin/bash\nset -o pipefail\n";
    if ($opts{opts}) { $opts{pbs_opts} = $opts{opts}; }
    if ($opts{pbs_opts} !~ /pbsfile=\s*(.+)\s*$/) {
        die "Invalid PBS options: $opts{pbs_opts}\n";
    }
    my $ff = $1;
    open(IN,$ff) ||
        die "Unable to open PBS options file '$ff': $!\n";
    while(<IN>) { print OUT $_; }
    close(IN);
    print OUT join(' ', @ARGV) . "\n";
    close(OUT);
    chmod(0755, $f);
    my $cmd = $opts{pbs_cmd} . ' ';
    $cmd .= $f;
    if ($opts{verbose}) { print STDERR "$me$mesuffix : " . uc($e) . " command=$cmd\n"; }
    my $rc = (0xffff & system($cmd)) >> 8;
    ####unlink($f);
    exit($rc);
}

#==================================================================
# Subroutine:
#   Run_SLURM_Engine($e)
#
# Arguments:
#   e - engine name (could specify a subset of possibilities)
#   Also uses @ARGV for commands to execute
#
# Return:
#   Does not return
#
#==================================================================
sub Run_SLURM_Engine {
    my ($e) = @_;

    #   Write the command to a shell script so pipes and such do not get confused
    my $f = $ENV{HOME} . "/z$$.sh";
    open(OUT, '>' . $f) || die "Unable to create script: $f:  $!\n";
    print OUT "#!/bin/bash\nset -o pipefail\n" . join(' ', @ARGV) . "\n";
    close(OUT);
    chmod(0755, $f);
    my $cmd = $opts{slurm_cmd} . ' ' . $opts{slurm_opts} . ' ' . $opts{opts} . ' ';
    $cmd .= $f;
    if ($opts{verbose}) { print STDERR "$me$mesuffix : " . uc($e) . " command=$cmd\n"; }
    my $rc = (0xffff & system($cmd)) >> 8;
    unlink($f);
    exit($rc);
}

exit;

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

runcluster.pl - Run a command from GotCloud on your local cluster

=head1 SYNOPSIS

  runcluster.pl slurm 'echo this is a command to run'
  runcluster.pl -opts "-w s03,s04 --mem 4g" slurm 'echo this is another command'
  runcluster.pl -opts "-w s03,s04 --mem 4g" slurm echo this is another command

  runcluster.pl pbs 'echo this is another command'
  runcluster.pl -opts "pbsfile=/home/tpg/.pbsfile2" pbs echo this is a third command

=head1 DESCRIPTION

Use this program as part of the GotCloud applications to run commands
in your local cluster.
This script may need to be modified for your cluster environment.


=head1 OPTIONS

=over 4

=item B<-help>

Generates this output.

=item B<-opts str>

Specifies the options to be passed to the program used to submit
jobs to your cluster.

Note that options to PBS engines typically use a file for all
the many options required. In this case the option is of the
form B<pbsfile=somefile> where the file I<somefile> consists
of only the #PBS comment lines you would normally put in a
script to be run.
The default file for PBS is B<$HOME/.pbsfile>.

=item B<-verbose>

Will generate additional messages about the running of this program.

=back

=head1 PARAMETERS

=over 4

=item B<engine_type>

Specifies the type of engine to submit the command to.
This can be slurm, local, sge, mosix and pbs.

=item B<command>

Specifies the command to be run in the cluster.
This string can be specified as one quoted parameter
(e.g. 'make -j 4 -f abc/Makefile') or
a number of arguments (e.g. make -j 4 -f abc/Makefile)
which will be assembled as the command to be executed.
Avoid the use of single quotes if at all possible as it will
be easy to get confused trying to escape the quotes.

=over 4


=head1 EXIT

If no fatal errors are detected, the program exits with a
return code of 0. Any error will set a non-zero return code.

=head1 AUTHOR

Written by Mary Kate Trost I<E<lt>mktrost@umich.eduE<gt>>.
This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; See http://www.gnu.org/copyleft/gpl.html

=cut
