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
use Cwd;
use Cwd 'abs_path';

my($me, $mepath, $mesuffix) = fileparse($0, '\.pl');
(my $version = '$Revision: 1.5 $ ') =~ tr/[0-9].//cd;
$mepath = abs_path($mepath);
if ($mepath !~ /(.*)\/scripts/) { die "No 'scripts' found in '$mepath'\n"; }
push @INC,$1 . '/bin';                  # use lib is a BEGIN block and does not work
require Multi;

my %opts = (
    opts => '',
    engine => 'slurm',
    concurrent => 1,
    verbose => 0,
);

Getopt::Long::GetOptions( \%opts,qw(
    help
    verbose
    concurrent=n
    engine=s
    opts=s
    file=s
)) || die "Failed to parse options\n";

#   Simple help if requested, sanity check input options
if ($opts{help}) {
    warn "$me$mesuffix [options] [type command]\n" .
        "Version $version\n" .
        "Use this to run a command for GotCloud in your local cluster.\n" .
        "This is typically called by Perl scripts in GotCloud\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}
my $engine;
my @c = ();
if ($opts{file}) {                          # Special hook to submit a file of commands
    open(IN, $opts{file}) ||
        die "Unable to open file '$opts{file}': $!\n";
    while (<IN>) {
        chomp();
        push @c,$_;
    }
    close(IN);
    warn "Read commands from '$opts{file}'\n";
    $engine = $opts{engine};                # How to submit this to run
}
else {
    $engine = shift(@ARGV) || '';
    @c = join(' ', @ARGV);
    $opts{engine} = $engine;
}


#   Check the path to the cwd will be visible in the batch environment
if ($opts{engine} eq 'mosix' || $opts{engine} eq 'mosbatch') {
    if (FixCWD()) {
        #warn "Current working directory set to '" . getcwd() . "'\n";
    }
}
if ($opts{verbose}) { $Multi::VERBOSE = 1; $Multi::VERBOSE = 1; }   # Twice avoids warning
exit Multi::RunCluster($engine, $opts{opts}, \@c, $opts{concurrent});

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
# TODO - we should make this a configurable option not hard-coded based
# on our system.
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
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

runcluster.pl - Run a command from GotCloud on your local cluster

=head1 SYNOPSIS

  runcluster.pl slurmi 'echo this is a command to run'
  runcluster.pl -opts "-w s03,s04 --mem 4g" slurmb 'echo this is another command'
  runcluster.pl -opts "-w s03,s04 --mem 4g" mosix echo this is another command

=head1 DESCRIPTION

Use this program as part of the GotCloud applications to run commands
in your local cluster.
This script may need to be modified for your cluster environment.


=head1 OPTIONS

=over 4

=item B<-concurrent N>

Specifies the number of concurrent tasks that might be run at once.
This defaults to '1'.
It only makes sense to specify this if you should be using
the file=path form for 'command' (see below).

=item B<-engine string>

Specifies the type of batch engine to use.
Common choices are mosix, mosbatch, slurmi, and slurm, but your
local installation might support others.
This defaults to 'slurm'.

=item B<-file path>

Specifies a file of commands to submit to the batch system.
You must either specify the B<-file> option or
specify the batch system and command as arguments to this command (see below).

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
#--------------------------------------------------------------

=over 4

=item B<engine_type>

If B<-file> was not specified, you must specify this argument.
Specifies the type of engine to submit the command to.
This can be slurm, local, sge, mosix and pbs.

=item B<command>

If B<-file> was not specified, you must specify this argument.
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
