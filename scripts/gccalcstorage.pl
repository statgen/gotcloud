#!/usr/bin/perl
#################################################################
#
# Name: gccalcstorage.pl process dir indexfile
#
# Description:
#   Use this to make an estimate of the storage requirements
#   for a GotCloud program.
#
# ChangeLog:
#   21 May 2013 tpg   Initial coding
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

#   output of align = 110% * size of FASTQ (bams)
#   temp files of umake = 120% of size of BAMs  (glf)
#   output of umake = 5% of BAMs  (vcf)
#
#   Here are examples of data in/out for align
#   SAMPLE   FASTQ  BAMs  ratio_bam alignment.aln bwa.sai.t alignment.pol   total_tmp  ratio_tmp
#   HG01052    17G   29G    1.7        18G         12G        18G+18G        59G       3.47
#   HG01069    18G   29G    1.6        18G         12G        18G+18G        59G       3.27
#   HG1098     12G   20G    1.67       13G         6.1G       13G+12G      44.1G       3.675
#   HG01188    25G   41G    1.64       27G         15G        27G+25G        94G       3.76
my %opts = (
    #   These apply to align
    fastq2bam_factor => 1.8,
    fastq2tmp_factor => 3.9,

    totalsize => 0,                     # For both

    #   These apply to snpcall
    bam2glf_factor => 0.50,             # Very poor choice for exome samples
    bam2vcf_factor => 0.22,
    bam2pvcf_factor => 0.011,
    bam2split_factor => 0.012,
);

Getopt::Long::GetOptions( \%opts,qw(
    help
    totalsize=s
)) || die "Failed to parse options\n";

#   Simple help if requested, sanity check input options
if ($opts{help} || $#ARGV < 1) {
    warn "$me$mesuffix [options] align indexfile prefix\n" .
        "  or\n" .
        "$me$mesuffix [options] snpcall indexfile\n" .
        "Use this to make an estimate of the storage requirements for GotCloud.\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}
my $fcn = shift(@ARGV);
if ($fcn =~ /(\S+)\./) { $fcn = $1; }

#-----------------------------------------------------------------
#   Show calculations for the choice
#-----------------------------------------------------------------
if ($opts{totalsize}) {             # Fix totalsize if provided
    if ($opts{totalsize} =~ /(.+)g$/i) { $opts{totalsize} = $1*1024*1024*1024 }
    if ($opts{totalsize} =~ /(.+)t$/i) { $opts{totalsize} = $1*1024*1024*1024*1024 }
}

if ($fcn eq 'align') {
    print AlignStorage($ARGV[0], $ARGV[1]);
    exit;
}
if ($fcn eq 'snpcall' || $fcn eq 'umake') {
    print UmakeStorage($ARGV[0], $ARGV[1]);
    exit;
}

die "Unknown function '$fcn'\n";
exit(1);

#--------------------------------------------------------------
#   AsGB (number)
#
#   Returns a string expressing number as GBs
#--------------------------------------------------------------
sub AsGB {
    return sprintf('%4.2f GB', $_[0]/(1024*1024*1024));
}

#--------------------------------------------------------------
#   AlignStorage (indexfile, prefix)
#
#   Returns a string showing the storage requirements for the aligner
#--------------------------------------------------------------
sub AlignStorage {
    my ($indexfile, $prefix) = @_;

    if (! defined $prefix) { $prefix=""; }
    #   Add the trailing / if not on the prefix.
    if ( ($prefix ne "") && ($prefix !~ /\/$/) ) { $prefix .= '/'; }

    my $totsize = 0;
    my $k = 0;
    if ($opts{totalsize}) {
        #   User really does not have a file, but knows the totalsize
        $totsize = $opts{totalsize};
        $k = '?';
    }
    else {
        #   Read the index file and get the size of each FASTQ file
        open(IN, $indexfile) ||
            die "Unable to open file '$indexfile': $!\n";
        $_ = <IN>;                    # Remove header, check it
        if ($_ =~ /^#FASTQ_PREFIX\s*=\s*(.+)\s*$/) {  # Provides reference path to fastq files
            $prefix = $1;
            $_ = <IN>;
        }
        if (! /MERGE_NAME/) { die "Index file '$indexfile' did not look correct\n  Line=$_"; }
        while (<IN>) {
            my @c = split(' ',$_);
            my $f = "$c[1]";
            # Check if the path is not absolute and needs the prefix.
            if ($f !~ /^\//) { $f = "$prefix$c[1]"; }

            my @stats = stat($f);
            if (! @stats) { die "Unable to find details on '$f': $!\n"; }
            $totsize += $stats[7];
            $k++;
            $f = "$c[2]";
            # Check if the path is not absolute and needs the prefix.
            if ($f !~ /^\//) { $f = "$prefix$c[2]"; }
            if ($f ne '.') {
                @stats = stat($f);
                if (! @stats) { die "Unable to find details on '$f': $!\n"; }
                $totsize += $stats[7];
                $k++;
            }
        }
        close(IN);
    }
    if (! $k) { die "No FASTQ files were found. This cannot be correct\n"; }

    my $s = "File sizes of $k FASTQ input files referenced in '$indexfile' = " . AsGB($totsize) . "\n";
    my $tmpsize = $opts{fastq2tmp_factor}*$totsize;
    $s .= "Total temp space will be about " . AsGB($tmpsize) . "\n";
    $tmpsize = $opts{fastq2bam_factor}*$totsize;
    $s .= "Total space for BAM files will be about " . AsGB($tmpsize) . "\n";
    $s .= "Be sure you have enough space to hold all this data\n";
    return $s;
}

#--------------------------------------------------------------
#   UmakeStorage (indexfile)
#
#   Returns a string showing the storage requirements for the snpcaller
#--------------------------------------------------------------
sub UmakeStorage {
    my ($indexfile) = @_;
    my $totsize = 0;
    my $k = 0;
    if ($opts{totalsize}) {
        #   User really does not have a file, but knows the totalsize
        $totsize = $opts{totalsize};
        $k = '?';
    }
    else {
        open(IN, $indexfile) ||
            die "Unable to open file '$indexfile': $!\n";
        while (<IN>) {
            #   Input line ~:  HG01055 ALL     /home/tpg/out/e/bams/HG01055.recal.bam
            my @c = split(' ',$_);
            my $f = $c[2];
            my @stats = stat($f);
            if (! @stats) { die "Unable to find details on '$f': $!\n"; }
            $totsize += $stats[7];
            $k++;
        }
        close(IN);
    }
    if (! $k) { die "No BAM files were found. This cannot be correct\n"; }

    my $s = "File sizes of $k BAM input files referenced in '$indexfile' = " . AsGB($totsize) . "\n";
    my $tmpsize = ($opts{bam2glf_factor}*$totsize);
    $s .= "GLF files from snpcaller will be about " . AsGB($tmpsize) . "\n";
    $tmpsize = ($opts{bam2vcf_factor}*$totsize);
    $s .= "VCF files from snpcaller will be about " . AsGB($tmpsize) . "\n";
    $tmpsize = ($opts{bam2pvcf_factor}*$totsize);
    $s .= "PVCF files from snpcaller will be about " . AsGB($tmpsize) . "\n";
    $tmpsize = ($opts{bam2split_factor}*$totsize);
    $s .= "Split files from snpcaller will be about " . AsGB($tmpsize) . "\n";
    $s .= "Be sure you have enough space to hold all this data\n";
    return $s;
}

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

gccalcstorage.pl - Estimate of the storage requirements for GotCloud

=head1 SYNOPSIS

  gccalcstorage.pl align  /mnt/1000g ePUR1.index
  gccalcstorage.pl -total 1365G align  /mnt/1000g ePUR1.index

=head1 DESCRIPTION

Use this program as part of the GotCloud applications to calculate
the approximate storage needed for the aligner or snpcaller steps.
This calculates the storage needed and generates messages to that effect.

=head1 OPTIONS

=over 4

=item B<-help>

Generates this output.

=item B<-totalsize SIZE>

If you specify the size of the FASTQs (perhaps because they are not immediately
available for the program to get their sizes), then this value will be
used to estimate the space needed.
SIZE should be a number in bytes or you may append 'G' or 'T' for gigabytes
or terabytes.
If this option is used, the indexfile will not be read and you may use
anything for it.

=back

=head1 PARAMETERS

=over 4

=item B<process>

Specifies the name of the program for which we calculate storage.
This should be B<align> or B<snpcall>.

=item B<dir>

Specifies the path to a directory which contains either the
B<fastq> or B<bam> files which serve as input to the process above.

=item B<indexfile>

Specifies the path to the index file of inputs to this process.
The fully qualified path to the file will be B<dir>/B<indexfile>.

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

