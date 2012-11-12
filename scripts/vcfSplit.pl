#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use IO::Zlib;

my $in = "";
my $out = "";
my $nunit = 10000;
my $noverlap = 1000;
my $filterflag = "";

my $result = GetOptions("in=s",\$in,
			"out=s",\$out,
			"nunit=i",\$nunit,
			"noverlap=i",\$noverlap,
			"filter",\$filterflag
    );

my $usage = "Usage: perl [vcfSplit.pl] --in=[$in] --out=[$out] --nunit=[$nunit]\n";

die "Error in parsing options\n$usage\n" unless ( ( $result ) && ( $in ) && ($out) ) ;

my $header = "";
my $gzFlag = ( $in =~ /\.gz$/ ) ? 1 : 0;

if ( $gzFlag ) {
    die "Cannot open file\n" unless ( -s $in );
    tie *IN, "IO::Zlib", $in, "rb";
}
else {
    open(IN,$in) || die "Cannot open file $in\n";
}
my $nsnps = 0;
my $curChunk = 0;
my @buffers = ();
my @vcfs = ();
while(<IN>) {
    if ( /^#/ ) {
	$header .= $_;
    }
    else {
	my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@genos) = split(/[\t\n]+/);
	next if ( $filterflag && ( $filter ne "PASS" ) );

	# 0-9999, 9000-18999, 18000-27999, ...
	if ( ( $nsnps == 0 ) || ( ( $nsnps > $noverlap ) && ( $nsnps % ($nunit - $noverlap) == $noverlap ) ) ) {
	    if ( $nsnps > 0 ) {
		if ( $gzFlag ) {
		    untie *OUT;
		}
		else {
		    close OUT;
		}
	    }
	    ++$curChunk;
	    my $ovcf = "$out.$curChunk.vcf";
	    print STDERR "Opening $ovcf...\n";
	    if ( $gzFlag ) {
		tie *OUT, "IO::Zlib", "$ovcf.gz", "wb" || die "Cannot open file\n";
	    }
	    else {
		open(OUT,">$ovcf") || die "Cannot open file\n";
	    }
	    push(@vcfs,$ovcf);
	    print OUT $header;
	    print OUT join("",@buffers);
	}
	print OUT $_;
	push(@buffers,$_);
	shift(@buffers) if ($#buffers + 1 > $noverlap);
	++$nsnps;
    }
}
if ( $gzFlag ) {
    untie *OUT;
}
else {
    close OUT;
}

if ( $gzFlag ) {
    untie *IN;
}
else {
    close IN;
}

open(OUT,">$out.vcflist") || die "Cannot open file\n";
if ( $gzFlag ) {
    print OUT join(".gz\n",@vcfs).".gz\n";
}
else {
    print OUT join("\n",@vcfs)."\n";
}
close OUT;
