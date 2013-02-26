#!/usr/bin/perl -w

use strict;
use Cwd;
use Getopt::Long;

die unless ($#ARGV > 0);

my ($unit,@vcfs) = @ARGV;

print STDERR "Start merging VCFs...\n";
my @indids = ();
my $headerMatchFlag = 1;
my $headerPrintedFlag = 0;

for(my $j=0; $j < @vcfs; ++$j) {
    my ($start,$end) = ($1,$2) if ( $vcfs[$j] =~ /\.(\d+)\.(\d+)(.stats)?.vcf$/ );
    die "Cannot recognize VCF file name $vcfs[$j]\n" unless ( defined($start) && defined($end) );
    #my $start = sprintf("%d",$j*$unit+1);
    #my $end = sprintf("%d",($j+1)*$unit);
    print STDERR "Merging $vcfs[$j] into STDOUT...\n";
    open(IN,$vcfs[$j]) || die "Cannot open file $vcfs[$j] for reading\n";
    my @headerBuffers = ();

    while(<IN>) {
	# Check the consistency of the headers across VCF files.
	# The header lines should be identical, except for the case with empty VCF files.
	if ( /^#CHROM/ ) {
	    my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@ids) = split(/[ \t\r\n]+/);
	    
	    # check if the header file contains valid individual IDs
	    my $validHeaderFlag = 1;
	    foreach my $id (@ids) {
		unless ( $id =~ /^[\x21-\x7F]+$/ ) {
		    $validHeaderFlag = 0;
		}
	    }
	    
	    if ( $validHeaderFlag == 0 ) {
		print STDERR "Invalid individual ID detected in $vcfs[$j]. Skipping..\n";
	    }
	    elsif ( $headerPrintedFlag == 0 ) {
		print join("",@headerBuffers);
		print $_;
		$headerPrintedFlag = 1;
		@indids = @ids;
	    }
	    else {
		# set headerMatchFlag
		if ( $#indids == $#ids ) {
		    $headerMatchFlag = 1;
		    for(my $i=0; $i < @ids; ++$i) {
			if ( $indids[$i] ne $ids[$i] ) {
			    print STDERR "$indids[$i] vs $ids[$i] mismatches\n";
			    $headerMatchFlag = 0;
			}
		    }
		}
		else {
		    $headerMatchFlag = 0;
		    print STDERR "$#indids vs $#ids mismatches\n";
		}
	    }
	}
	elsif ( /^#/ ) {
	    push(@headerBuffers,$_);
	}
	else {
	    die "Header does not match with previous files at $vcfs[$j]\n" if ( $headerMatchFlag == 0 );
	    
	    my ($chr,$pos) = split(/[ \t\r\n]+/);
	    
	    if ( ( $pos >= $start ) && ( $pos <= $end ) ) {
		print $_;
	    }
	    else {
		print STDERR "Ignoring $chr:$pos in $vcfs[$j] when merging into output\n";
	    }
	}
    }
    close IN;
}

#     my $maxDP = 20000;
#     my $minDP = 500;
#     my $indelVCF = "/share/swg/hmkang/data/1000G/pilot_indels_2010_07/chr20/1kg.pilot_release.merged.indels.sites.hg19.chr20.vcf";
#     my $winIndel = 5;
#     my $cmd = "time /share/swg/hmkang/bin/mcall/vcfCooker.20101225 --in-vcf $outvcf --out $outprefix.filtered.vcf --upgrade --write-vcf --filter --maxAB 67 --maxDP $maxDP --winIndel $winIndel --indelVCF $indelVCF --maxSTR 15 --minSTR -15 --minDP $minDP --minQUAL 5";
#     &runCmd($cmd);

#     $cmd = "time cut -f 1-8 $outprefix.filtered.vcf > $outprefix.filtered.sites.vcf";
#     &runCmd($cmd);

#     $cmd = "time perl /share/swg/hmkang/bin/mcall/mpipeline-summarize-vcf.pl --vcf $outprefix.filtered.sites.vcf --dbSNP /share/swg/hmkang/data/dbSNP/chr20/dbsnp_129_b37.rod.chr20.map --FNRbfile data/HapMap/chr20/hapmap3_r3_b37_fwd.consensus.qc.602.poly.chr20 > $outprefix.filtered.sites.vcf.summary";
#     &runCmd($cmd);

