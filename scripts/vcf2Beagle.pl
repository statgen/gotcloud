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
my $outf = ""; # output beagle likelihood file
my $indf = ""; # individual IDs to subselect
my $PLflag = ""; # Use phred-scale likelihood instead of raw likelihood (default : OFF)
my $filterflag = ""; # Use only filtered SNPs
my $convFlag = "";

my $result = GetOptions("in=s",\$invcf,
			"out=s",\$outf,
			"ind=s",\$indf,
			"PL",\$PLflag,
			"conv",\$convFlag,
			"filter",\$filterflag
    );

my $usage = "Usage: perl vcf2beagle.pl --in=[$invcf] --out=[$outf] --ind=[$indf] --PL --filter\n";

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
	my $GLidx = -1;
	my $GL3flag = 0;
	for(my $i=0; $i < @formats; ++$i) {
	    if ( $formats[$i] eq "GL" ) {
		$GLidx = $i;
	    }
	    elsif ( $formats[$i] eq "GL3" ) {
		$GLidx = $i;
		$GL3flag = 1;
	    }
	    elsif ( $formats[$i] eq "PL" ) {
		$GLidx = $i;
		die "Observed PL in FORMAT field without --PL option" unless ($PLflag);
	    }
	}
	my @liks = ();
	my $missingFlag = 0;
	for(my $i=0; $i < @iids; ++$i) {
	    # if missing genotype is observed, make the likelihood equal
	    if ( $ids[$iids[$i]] eq "\.\/\." ) {
		#$missingFlag = 1;
		#last;
		push(@liks,"1.000000");
		push(@liks,"1.000000");
		push(@liks,"1.000000");
	    }
	    else {
		my @c = split(/:/,$ids[$iids[$i]]);
		my @GLs = split(/,/,$c[$GLidx]);
		for(my $i=0; $i < @GLs; ++$i) {
		    $GLs[$i] = 0 if ( $GLs[$i] eq "." );
		}

		if ( $PLflag ) {
		    if ( $GL3flag ) {
			push(@liks,sprintf("%.6lf",pow(0.1,$GLs[2]/10.)));
			push(@liks,sprintf("%.6lf",pow(0.1,$GLs[4]/10.)));
			push(@liks,sprintf("%.6lf",pow(0.1,$GLs[5]/10.)));
		    }
		    else {
			push(@liks,sprintf("%.6lf",pow(0.1,$GLs[0]/10.)));
			push(@liks,sprintf("%.6lf",pow(0.1,$GLs[1]/10.)));
			push(@liks,sprintf("%.6lf",pow(0.1,$GLs[2]/10.)));
		    }
		}
		else {
		    if ( $GL3flag ) {
			push(@liks,sprintf("%.6lf",pow(10,$GLs[2])));
			push(@liks,sprintf("%.6lf",pow(10,$GLs[4])));
			push(@liks,sprintf("%.6lf",pow(10,$GLs[5])));
		    }
		    else {
			push(@liks,sprintf("%.6lf",pow(10,$GLs[0])));
			push(@liks,sprintf("%.6lf",pow(10,$GLs[1])));
			push(@liks,sprintf("%.6lf",pow(10,$GLs[2])));
		    }
		}
	    }
	}

	#if ( $missingFlag == 0 ) {
	print OUT "$chr:$pos";
	if ( $convFlag ) { ## if convFlag is set, always $ref = A $alt = C
	    print OUT " A C ";
	}
	else {
	    if ( length($alt) == 1 ) {
		print OUT " $ref $alt ";
	    }
	    else {
		my ($a1,$a2) = split(/,/,$alt);
		print OUT " $a1 $a2 ";
	    }
	}
	print OUT join(" ",@liks);
	print OUT "\n";
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
