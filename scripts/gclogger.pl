#!/usr/bin/env perl
#################################################################
#
# Name: gclogger.pl write to a log file
#
# Description:
#   Use this to write an entry to a log file in a controlled manner
#
# ChangeLog:
#   25 June 2014 tpg    Initial coding
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
my %opts = (
);
Getopt::Long::GetOptions( \%opts,qw(
    help
    nolock
)) || die "Failed to parse options\n";

my $key = shift(@ARGV);
my $logfile = shift(@ARGV);

#   Simple help if requested, sanity check input options
if ($opts{help} || $#ARGV < 0) {
    warn "$me$mesuffix [options] key logfile message\n" .
        "Use this to write an entry to a log file in a controlled manner.\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}
my $msg = join(' ', @ARGV);
if (-e $logfile && (! -f $logfile)) {
    die "'$logfile' is not a regular file to which we can append a message\n$msg\n";
}

#-----------------------------------------------------------------
#   Construct message, then append to $logfile
#-----------------------------------------------------------------
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $d = sprintf('%04s-%02d-%02d %02s:%02d:%02d', $year+1900, $mon+1, $mday, $hour, $min, $sec);
$key = sprintf('%-12s', $key);

open(LOGFILE, '>>' . $logfile) ||
    die "Unable to append to file '$logfile': $!\n";
if (! $opts{nolock}) {
    flock(LOGFILE, 2) ||
        die "Unable to obtain lock for '$logfile': $!\n";
}
print LOGFILE $key . ' ' . $d . ' ' . $msg . "\n";
close(LOGFILE);
exit;

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

gclogger.pl - Write to a log file

=head1 SYNOPSIS

  gclogger.pl step2 /tmp/log.file "Start of second step"
  gclogger.pl step2 /tmp/log.file End of second step

=head1 DESCRIPTION

Use this program to append to a log file in a controlled manner.
The logfile is locked (or we wait until the lock is obtained)
and the message is appended with a date prepended along with
the keyname provided.

The examples above would result in a file that looks like:
  step2        21014-06-25 13:40:12 Start of second step
  step2        2014-06-25 13:40:22 End of second step


=head1 OPTIONS

=over 4

=item B<-help>

Generates this output.

=item B<-nolock>

If specified no attempt is made to lock the logfile.

=back

=head1 PARAMETERS

=over 4

=item B<keyname>

Specifies a string which can serve to identify the entry in the log file.

=item B<logfile>

Specifies the path to a file to be created or appended to.

=item B<message>

Specifies the string to be appended to the log file.

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

