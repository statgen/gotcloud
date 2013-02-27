#!/usr/bin/perl
#################################################################
#
# Name: make_indexfile.pl
#
# Description:
#   Use this to create an indexFile.txt for the aligner
#   The output from this may not be completely correct
#   but it beats making such a file by hand.
#
# Output:
#   indexFile looks something like:
#   #   #   Paths are relative to ...this...long...path
#   MERGE_NAME  FASTQ1  FASTQ2  RGID    SAMPLE  LIBRARY CENTER  PLATFORM
#   Sample1 fastq/Sample_1/File1_R1.fastq.gz    fastq/Sample_1/File1_R2.fastq.gz    RGID1   SampleID1   Lib1    UM  ILLUMINA
#
# ChangeLog:
#    5 Feb 2013 tpg   Initial coding
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

my($me, $mepath, $mesuffix) = fileparse($0, '\.pl');
(my $version = '$Revision: 1.5 $ ') =~ tr/[0-9].//cd;

#--------------------------------------------------------------
#   Initialization - Sort out the options and parameters
#--------------------------------------------------------------
my %opts = (
    library => 'Lib1',
    center => 'UM',
    platform => 'ILLUMINA',
    path => '.',
);
Getopt::Long::GetOptions( \%opts,qw(
    help verbose replace library=s center=s platform=s path=s
    )) || die "Failed to parse options\n";

#   Simple help if requested
if ($opts{help} || $#ARGV < 0) {
    warn "$me$mesuffix [options] -path /path/to/fastqfiles indexfile_to_create\n" .
        "Version $version\n" .
        "Use this to create an indexFile.txt for the aligner.\n" .
        "The output from this may not be completely correct\n" .
        "but it beats making such a file by hand.\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}
my $ofile = shift(@ARGV);
if (-r $ofile and ! $opts{replace}) {
    die "File '$ofile' already exists and -replace was not specified\n";
}

#   Check if this might possibly be a valid source of fastq files
my @samples = `ls $opts{path}/*/*.fastq.gz 2> /dev/null`;
if (! @samples) {
    die "No fastq files were found in the directories under '$opts{path}'. " .
        "This cannot be correct.\n";
}

#--------------------------------------------------------------
#   Create index file
#   Walk directories of samples, getting all FASTQ files
#--------------------------------------------------------------
if ($opts{replace}) { unlink($ofile); }
open(OUT, '>' . $ofile) ||
    die "Unable to create file '$ofile': $!\n";

chdir($opts{path}) ||
    die "Unable to CD to '$opts{path}'\n";
my $here = getcwd();
print OUT "#FASTQ_REF=$here\n";
print OUT "MERGE_NAME\tFASTQ1\tFASTQ2\tRGID\tSAMPLE\tLIBRARY\tCENTER\tPLATFORM\n";

#   Get directories of samples

opendir(DIR, '.') ||
    die "Unable to open directory '$here': $!\n";
@samples = ();
while(readdir(DIR)) {
    if (/^\./) { next; }
    if (-d $_) { push @samples, $_; }
}
closedir(DIR);
print "Found " . ($#samples+1) . " samples\n";

#   Get FASTQ files for each directory
foreach my $sample (sort @samples) {
    opendir(DIR, $sample) ||
        die "Unable to open directory '$sample': $!\n";
    my %fastqs = ();
    while(readdir(DIR)) {
        if (/^\./) { next; }
        if (/\.fastq.gz/) { $fastqs{$_} = 1; }
    }
    closedir(DIR);
    my @fastqfiles = sort keys %fastqs;
    print "  Found " . ($#fastqfiles+1) . " FASTQs under $sample\n";

    #   For each pair of FASTQs  (R1 and R2), generate an index line
    foreach my $fq (@fastqfiles) {
        if ($fq !~ /^(\w+)(L\d+)_R1_(\w+)\.fastq.gz/) { next; }
        my ($p1, $p2, $p3) = ($1, $2, $3);
        my $fq1 = $p1 . $p2 . '_R1_' . $p3 . '.fastq.gz';
        my $fq2 = $p1 . $p2 . '_R2_' . $p3 . '.fastq.gz';
        if (! -r "$sample/$fq1") { die "Unable to read file '$sample/$fq1'\n"; }
        if (! -r "$sample/$fq2") { die "Unable to read file '$sample/$fq2'\n"; }
        print OUT "$sample\t$sample/$fq1\t$sample/$fq2\tRG$p2\t$sample\t" .
            "$opts{library}\t$opts{center}\t$opts{platform}\n";
    }
}
close(OUT);

#   All done, clean up and exit
print "Created index '$ofile' for the aligner.  Correct as necessary/n";
exit;

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

make_indexfile.pl - Create an indexFile for the GotCloud aligner

=head1 SYNOPSIS

  make_indexfile.pl -path ~/myseq/data/fastq  attempt1.indexFile.txt
  make_indexfile.pl -replace -path ~/myseq/data/fastq  attempt1.indexFile.txt


=head1 DESCRIPTION

Use this program to generate the indexFile required by the GotCloud
aligner, align.pl.
All you need do is provide the path to the directory where the FASTQ
files are to be found, and this program will generate an indexFile
suitable for the aligner.

Note: You may need to edit this file and correct the RG values
for the FASTQ files.


=head1 OPTIONS

=over 4

=item B<-center str>

Specifies the center in the indexFile. This defaults to 'UM'.

=item B<-help>

Generates this output.

=item B<-library str>

Specifies the library in the indexFile. This defaults to 'Lib1'.

=item B<-path str>

Specifies the path to the fastq files. This defaults to '.'.

=item B<-platform str>

Specifies the platform in the indexFile. This defaults to 'ILLUMINA'.

=item B<-replace>

Specifies that if necesary the program should replace any existing
indexfile that is to be created.

=back


=head1 PARAMETERS

=over 4

=item B<indexfile>

Specifies the path to the indexFile to be created.

=over 4


=head1 EXIT

If no fatal errors are detected, the program exits with a
return code of 0. Any error will set a non-zero return code.


=head1 AUTHOR

Written by Mary Kate Wing I<E<lt>mktrost@umich.eduE<gt>>.
This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; See http://www.gnu.org/copyleft/gpl.html

=cut
