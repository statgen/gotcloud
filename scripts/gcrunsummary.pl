#!/usr/bin/perl
#################################################################
#
# Name: gcrunsummary.pl generate summary of a run
#
# Description:
#   Use this to create a simple summary of how long various
#   steps took in an aligner or snpcaller run
#
#   Role this all together with something like this mess:
#   dirs="GC8G-Single15LCEBS.out GC8G-SingleLC2EBS.out GC8G-SingleLCEBS.out GC-dumbo.out  GC-Single3.0.out GC-Single3.1.out GC-Single3dumbo GC-Single3EBS.out GC-Single4EBS.out GC-Single4.out GC-SingleLC.0.out GC-SingleLCdumbo GC-SingleLCEBS.out"
#   clear;rm -f /tmp/j.csv
#   for d in $dirs; do echo "==== $d"; /tmp/gcrunsummary.pl -csv /tmp/jj align $d; grep -v Direct /tmp/jj >> /tmp/j.csv; done
#   head -1 /tmp/jj > /tmp/j; cat /tmp/j.csv >> /tmp/j; mv /tmp/j /tmp/j.csv
#
# ChangeLog:
#   02 Jul 2013 tpg   Initial coding
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
    help csv=s
)) || die "Failed to parse options\n";

#   Simple help if requested, sanity check input options
if ($opts{help} || $#ARGV < 1) {
    warn "$me$mesuffix [options] align/snpcall outdir\n" .
        "Use this to create a simple summary of how long various\n" .
        "steps took in an aligner or snpcaller run.\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}
my $fcn = shift(@ARGV);
chdir $ARGV[0] ||
    die "Unable to CD to '$ARGV[0]': $!\n";

if ($fcn eq 'align') {
    AlignSummary(@ARGV);
    exit;
}
if ($fcn eq 'snpcall' || $fcn eq 'umake') {
    SNPCallSummary(@ARGV);
    exit;
}

die "Unknown function '$fcn'\n";
exit(1);

#--------------------------------------------------------------
#   AlignSummary (outdir)
#
#   Run through current working directory getting timestamps for *.done files
#   which looks like:
#       1372600723 ./tmp/alignment.aln/data/HG01055/sequence_read/SRR069527.filt.bam.done
#       65 ./tmp/alignment.pol/data/HG01055/sequence_read/SRR069527.filt.bam.done
#       45679 ./tmp/alignment.aln/data/HG01055/sequence_read/SRR069527_1.filt.bam.done
#       7541 ./tmp/alignment.pol/HG01055.merged.bam.done
#       4912 ./tmp/alignment.dedup/HG01055.dedup.bam.done
#       16710 ./lc/bams/HG01055.recal.bam.done
#       3461 ./lc/QCFiles/HG01055.genoCheck.done
#--------------------------------------------------------------
sub AlignSummary {
    my ($outdir) = @_;

    # Base the starttime on the latest starttime of any of the Makefiles.
    my $starttime = `find -name "\*.Makefile" | xargs stat -c "%Y" | sort |tail -n 1` || die "FAILED to find any *.Makefile files in $outdir\n";

    my $cmd = "find -name " . '\*.done -exec stat -c "%Y {}" {} \;' .
        " | sort | awk 'BEGIN{prev=$starttime;} {print \$1-prev \" \" \$2; prev=\$1;}'";
    open(IN, $cmd . ' | ') ||
        die "Unable to execute command '$cmd': $!\n";
    my @lines = <IN>;
    close(IN);
    if (! @lines) {
        die "No *.done files found in any sub-directory of '$outdir'\n" .
            "You need to specify the GotCloud options '--keeptmp --keeplog' for these files to be found.\n";
    }

    #   Collect details for each step in a hash
    my %details = ();
    foreach (@lines) {
        if (/^(\d+) .+\/alignment\.aln.+.bam.done/) {
            $details{"2) aln"} += $1;
            next;
        }
        if (/^(\d+) .+\/alignment\.pol.+merged.bam.done/) {
            $details{"4) merged"} += $1;
            next;
        }
        if (/^(\d+) .+\/alignment\.pol.+.bam.done/) {
            $details{"3) polish"} += $1;
            next;
        }
        if (/^(\d+) .+\/alignment\.dedup.+dedup.bam.done/) {
            $details{") dedup"} += $1;
            next;
        }
        if (/^(\d+) .+\/bwa\.sai\.t.+.sai.done/) {
            $details{"1) sai"} += $1;
            next;
        }
        if (/^(\d+) .+\/bams\/.+recal.bam.done/) {
            $details{"5) recal"} += $1;
            next;
        }
        if (/^(\d+) .+\/bams\/.+recal.bam.bai.done/) {
            $details{"6) index"} += $1;
            next;
        }
        if (/^(\d+) .+\/QCFiles\/.+genoCheck.done/) {
            $details{"7) verifyBamID"} = $1;
            next;
        }
        if (/^(\d+) .+\/QCFiles\/.+qplot.done/) {
            $details{"8) qplot"} = $1;
            next;
        }
        warn "Unable to parse line: $_\n";
    }

    #   Generate summary here
    my $total = 0;
    foreach my $key (sort keys %details) {
        printf("Step %-15s required %d seconds\n", $key, $details{$key});
        $total += $details{$key};
    }
    printf("\nTotal run time = %4.2f hours (%d seconds)\n", $total/3600, $total);

    #   Generate data as CSV if required
    if (! $opts{csv}) { return; }
    open(OUT, '>' . $opts{csv}) ||
        die "Unable to created CSV file '$opts{csv}': $!\n";
    my $h = 'Directory,';
    my $s = $outdir . ',';
    foreach my $key (sort keys %details) {
        $h .= $key . ',';
        $s .= $details{$key} . ',';
    }
    chop($h);
    chop($s);
    print OUT $h . "\n" . $s . "\n";
    warn "\nCreated CSV line in file '$opts{csv}\n";
}

#--------------------------------------------------------------
#   SNPCallSummary (indexfile)
#
#   Run through current working directory getting timestamps for *.done files
#   and make some sort of summary from them.
#--------------------------------------------------------------
sub SNPCallSummary {
    my ($outdir) = @_;
    die "SNPCallSummary($outdir) is not ready yet\n";
}

#==================================================================
#   Perldoc DocumentationCorrected time for first line from 1368989245 to 11916
#==================================================================
__END__

=head1 NAME

gcrunsummary.pl - generate summary of a GotCloud run

=head1 SYNOPSIS

  gcrunsummary.pl align    /mnt/out
  gcrunsummary.pl snpcall  /mnt/out

=head1 DESCRIPTION

Use this to create a simple summary of how long various
steps took in an aligner or snpcaller run.


=head1 OPTIONS

=over 4

=item B<-csv file>

Specifies that the summary should be written to B<file> in CSV format.

=item B<-help>

Generates this output.

=back


=head1 PARAMETERS

=over 4

=item B<process>

Specifies the name of the program for which we calculate storage.
This should be B<align> or B<snpcall>.

=item B<dir>

Specifies the path to a directory which contains the output of a run.
You need to specify the GotCloud options '--keeptmp --keeplog' so that
the correct files can be found.

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

