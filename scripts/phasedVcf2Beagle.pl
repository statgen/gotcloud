#!/usr/bin/perl -w

#################################################################
# vcf2beagle.pl
# convert VCF files (with GL or PL tags) into beagle input files
# (compatible with glfMultiples and GATK)
#################################################################

use strict;
use POSIX qw(log exp pow);
use Getopt::Long;
use IO::Zlib;

my $invcf = "";  # input VCF
my $outf = ""; # output phased beagle file
my $indf = ""; # individual IDs to subselect
my $filterflag = ""; # Use only filtered SNPs

my $result = GetOptions("in=s",\$invcf,
			"out=s",\$outf,
			"ind=s",\$indf,
			"filter",\$filterflag
    );

my $usage = "Usage: perl phasedVcf2beagle.pl --in=[$invcf] --out=[$outf] --ind=[$indf] --filter\n";

die "Error in parising options\n$usage\n" unless ( ($result) && ($invcf) && ($outf ) );

# Open individual IDs to subselect if exist
my %hIDs = ();
my $nIDs = 0;

if ( $indf ) {
    open(IN,$indf) || die "Cannot open file $indf\n";
    while(<IN>) {
	my ($indid) = split;
	$hIDs{$indid} = 1;
	++$nIDs;
    }
    close IN;
}

# open input and output files
die "Cannot open file $invcf for reading" unless ( -s $invcf );
if ( $invcf =~ /\.gz$/ ) {
    tie *IN, "IO::Zlib", $invcf, "rb";
}
else {
    open(IN,$invcf);
}

if ( $outf =~ /\.gz$/ ) {
    tie *OUT, "IO::Zlib", $outf, "wb";
}
else {
    open(OUT,">$outf") || die "Cannot open file $outf for writing\n";
}
open(MARKER,">$outf.marker") || die "Cannot open file $outf.marker for writing\n";

my @iids = (); # indices to include
while(<IN>) {
    if ( /^##/ ) { 
	# skip meta lines
    }
    elsif ( /^#CHROM/ ) {
	my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@ids) = split(/[\t\r\n]+/);
	print OUT "marker alleleA alleleB";
	for(my $i=0; $i < @ids; ++$i) {
	    if ( ( $nIDs == 0 ) || ( defined($hIDs{$ids[$i]}) ) ) {
		push(@iids,$i);
		print OUT " $ids[$i] $ids[$i] $ids[$i]";
	    }
	}
	print OUT "\n";
    }
    else {
	my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@ids) = split(/[\t\r\n]+/);

	next if ( ( $filterflag ) && ( $filter ne "PASS" ) && ( $filter ne "." ) && ( $filter ne "0" ) );

	$ref = uc($ref);
	$alt = uc($alt);

	my @formats = split(/:/,$format);
	my $GTidx = -1;
	for(my $i=0; $i < @formats; ++$i) {
	    if ( $formats[$i] eq "GT" ) {
		$GTidx = $i;
	    }
	}
	my @GTs = ();
	my @as = ($ref,$alt);
	my $offset = 0;
	if ( length($alt) > 1 ) {
	    @as = ($ref,split(/,/,$alt));
	}
	for(my $i=0; $i < @iids; ++$i) {
	    # if missing genotype is observed, make the likelihood equal
	    if ( $ids[$iids[$i]] eq "(\d)|(\d)" ) {
		push(@GTs,$as[$1],$as[$2]);
	    }
	    else {
		die "Cannot parse GT field from $ids[$iids[$i]] at $chr:$pos\n";
	    }
	}
	print OUT "M\t$chr:$pos\t";
	print OUT join("\t",@GTs);
	print OUT "\n";
	print MARKER "$chr:$pos\t$pos\t".$as[$#as-1]."\t".$as[$#as]."\n";
    }
}

if ( $invcf =~ /\.gz$/ ) {
    untie *IN;
}
else {
    close IN;
}
if ( $outf =~ /\.gz$/ ) {
    untie *OUT;
}
else {
    close OUT;
}
close MARKER;
