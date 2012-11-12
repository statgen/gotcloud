#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use IO::Zlib;
#use lib "/home/hmkang/lib/perl";
#use libVcf;

my $vcf = "";
my $dbSNPf = "";
my $FNRbfile = "";
my $FNRvcf = "";
my $MAFthres = 0;
my $monoFlag = "";
my $defaultFlag = "";
my $chr = "";
my $defaultDbsnp = "/net/fantasia/home/hmkang/data/dbSNP/b129.ncbi37/dbsnp_129_b37.rod";
my $defaultHM3 = "/net/fantasia/home/hmkang/data/HapMap/ALL/hapmap3_r3_b37_fwd.consensus.qc.poly";

my $result = GetOptions("vcf=s",\$vcf,
			"dbsnp=s",\$dbSNPf,
			"FNRvcf=s",\$FNRvcf,
			"FNRbfile=s",\$FNRbfile,
			"MAFthres=f",\$MAFthres,
			"chr=i",\$chr,
			"default",\$defaultFlag,
			"mono",\$monoFlag
    );

die "Error in parsing options\n" unless ( ($result) );

my %hdbsnps = ();
if ( $defaultFlag ) {
    if ( $chr ) {
	$dbSNPf = "$defaultDbsnp.chr$chr.map";
	$FNRbfile = "$defaultHM3.chr$chr";
    }
    else {
	$dbSNPf = "$defaultDbsnp.map";
	$FNRbfile = "$defaultHM3";
    }
}

if ( $dbSNPf ) {
    print STDERR "loading $dbSNPf\n";
    open(IN,$dbSNPf) || die "Cannot open file\n";
    while(<IN>) {
	my ($chr,$rs,$bp) = split;
	if ( $bp ) {
	    $hdbsnps{"$chr:".($bp+1)} = 1;
	}
    }
    close IN;
    print STDERR "finished loading dbSNP\n";
}
else {
    print STDERR "Skipped loading dbSNP\n";
}

my %hFNRs = ();
my $nFNR = 0;
if ( $FNRbfile ) {
    print STDERR "loading FNR evaluation sites from $FNRbfile\n";
    open(IN,"$FNRbfile.bim") || die "Cannot open file\n";
    open(IN2,"$FNRbfile.frq") || die "Cannot open file\n";
    my $line = <IN2>;
    while(<IN>) {
	my ($chr,$snpid,$cM,$bp,$a1,$a2) = split;
	if ( $chr > 22 ) {
	    if ( $chr == 23 ) { $chr = "X"; }
	    elsif ( $chr == 24 ) { $chr = "Y"; }
	    elsif ( $chr == 25 ) { $chr = "XY"; }
	    elsif ( $chr == 26 ) { $chr = "MT"; }
	}
	my ($dummy,$chr2,$snpid2,$b1,$b2,$maf,$nchrobs) = split(/\s+/,<IN2>);
	die "$snpid != $snpid2\n" unless ($snpid eq $snpid2);
	if ( $monoFlag ) {
	    if ( ($maf ne "NA") && ( ( $maf == 0 ) || ( $maf == 1 ) ) ) {
		++$nFNR;
		$hFNRs{"$chr:$bp"} = $snpid;
	    }
	}
	else {
	    if ( ($maf ne "NA") && ( $maf > $MAFthres ) && ( $maf < 1-$MAFthres ) ) {
		++$nFNR;
		$hFNRs{"$chr:$bp"} = $snpid;
	    }
	}
    }
    close IN;
    close IN2;
    print STDERR "finished loading $nFNR FNR evaluation sites\n";
}
elsif ( $FNRvcf ) {
    open(IN,$FNRvcf) || die "Cannot open file\n";
    while(<IN>) {
	next if ( /^#/ );
	my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info) = split(/[\t\r\n]/);
	my $maf = 0;
	if ( $info =~ /AC=(\d+);/ ) {
	    my $AC = $1;
	    if ( $info =~ /AN=(\d)+1;/ ) {
		$maf = $1/$AC;
	    }
	    else {
		$maf = 0.01 if ( $1 > 0 );
	    }
	}
	elsif ( $info =~ /AF=([\d\.]+)[;$]/ ) {
	    $maf = $1;
	}

	if ( $monoFlag ) {
	    if ( ($maf ne "NA") && ( ( $maf == 0 ) || ( $maf == 1 ) ) ) {
		++$nFNR;
		$hFNRs{"$chrom:$pos"} = $id;
	    }
	}
	else {
	    if ( ($maf ne "NA") && ( $maf > $MAFthres ) && ( $maf < 1-$MAFthres ) ) {
		++$nFNR;
		$hFNRs{"$chrom:$pos"} = $id;
	    }
	}
    }
    close IN;
}
else {
    print STDERR "Skipped loading FNR evaluation sites\n";
}

#my ($fh,$ninds,$riids,$rhiids) = &openVCF($ARGV[0]);
if ( $vcf eq "" ) {
*IN = *STDIN;
}
elsif ( $vcf =~ /\.gz$/ ) {
    tie (*IN, "IO::Zlib", $vcf, "rb") || die "Cannot open file $vcf\n";
}
else {
    open(IN,$vcf) || die "Cannot open file $vcf\n";
}
my %hcnts = ();
my %mcnts = ();
while(<IN>) {
#    last if ( $. > 100000 );
    if ( /^([^#]\S*)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)/ ) {
	my ($chrom,$pos,$id,$ref,$alt,$qual,$filter) = ($1,$2,$3,$4,$5,$6,$7);
#while( my ($chrom, $pos, $id, $ref, $alt, $filter, $info, $rgenos) = &iterateVCF($fh, 0) ) {
	$ref = uc($ref);
	$alt = uc($alt);
	#$ref =~ s/1234/ACGT/g;
	#$alt =~ s/1234/ACGT/g;

	my @filters = split(/;/,$filter);
	unless ( defined($hcnts{$filter}) ) {
	    $hcnts{$filter} = [0,0,0,0,0,0,0];  # #SNPS, #dbSNP, #TsOld, #TvOld, #TsNew, #TvOld, #FNR
	}

	foreach my $f (@filters) {
	    unless ( defined($mcnts{$f}) ) {
		$mcnts{$f} = [0,0,0,0,0,0,0];
	    }
	}

	my $refalt = $ref.$alt;
	my $dbsnpFlag = 0;
	if ( ( ( $dbSNPf eq "" ) && ( $id =~ /^rs/ ) ) || ( ( $dbSNPf ne "" ) && ( defined($hdbsnps{"$chrom:$pos"}) ) ) ) {
	    ++($hcnts{$filter}->[1]);
	    $dbsnpFlag = 1;

	    foreach my $f (@filters) {
		++($mcnts{$f}->[1]);
	    }
	}

	if ( ( $refalt eq "AG" ) || ( $refalt eq "GA" ) || ( $refalt eq "TC") || ( $refalt eq "CT" ) ) {
	    ++($hcnts{$filter}->[($dbsnpFlag == 1) ? 2 : 4]);

	    foreach my $f (@filters) {
		++($mcnts{$f}->[($dbsnpFlag == 1) ? 2 : 4]);
	    }
	}
	elsif ( ( $ref ne $alt ) && ( $refalt =~ /^[ACGT][ACGT]$/ ) ) {
	    ++($hcnts{$filter}->[($dbsnpFlag == 1) ? 3 : 5]);

	    foreach my $f (@filters) {
		++($mcnts{$f}->[($dbsnpFlag == 1) ? 3 : 5]);
	    }
	}
	if ( defined($hFNRs{"$chrom:$pos"}) ) {
	    ++($hcnts{$filter}->[6]);

	    foreach my $f (@filters) {
		++($mcnts{$f}->[6]);
	    }
	}
	++($hcnts{$filter}->[0]);
	foreach my $f (@filters) {
	    ++($mcnts{$f}->[0]);
	}
    }
    elsif ( /^#/ ) {
	next;
    }
    else {
	die "Unrecognized VCF line $_\n";
    }
}

if ( $vcf =~ /\.gz$/ ) {
    untie *IN;
}
else {
    close IN;
}

my @totals = (0,0,0,0,0,0,0);
my @passes = (0,0,0,0,0,0,0);
my @fails  = (0,0,0,0,0,0,0);
print "------------------------------------------------------------------------------------------------------------\n";
print sprintf("%20s","FILTER")."\t#SNPs\t#dbSNP\t%dbSNP\tKnown\tNovel\tOverall\t%HM3\t%HM3\n";
print sprintf("%20s","")."\t\t\t\tTs/Tv\tTs/Tv\tTs/Tv\tsens\t/SNP\n";
print "------------------------------------------------------------------------------------------------------------\n";

foreach my $key (sort keys %hcnts) {
    for(my $i=0; $i < @totals; ++$i) {
	$totals[$i] += $hcnts{$key}->[$i];
	if ( ( $key eq "PASS" ) || ( $key eq "0" ) ) {
	    $passes[$i] += $hcnts{$key}->[$i];	    
	}
	else {
	    $fails[$i] += $hcnts{$key}->[$i];
	}
    }
    print sprintf("%20s",$key)."\t".($hcnts{$key}->[0])."\t".($hcnts{$key}->[1])."\t".sprintf("%.1lf",$hcnts{$key}->[1]*100/$hcnts{$key}->[0]);
    print ( ($hcnts{$key}->[3] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$hcnts{$key}->[2]/$hcnts{$key}->[3]) );
    print ( ($hcnts{$key}->[5] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$hcnts{$key}->[4]/$hcnts{$key}->[5]) );
    print ( ($hcnts{$key}->[5] + $hcnts{$key}->[3] == 0) ? "\tInf" : sprintf("\t%.2lf",($hcnts{$key}->[4]+$hcnts{$key}->[2])/($hcnts{$key}->[5]+$hcnts{$key}->[3]) ) );
    printf("\t%.3lf",100*($hcnts{$key}->[6]/($nFNR+1e-6)));
    printf("\t%.3lf\n",100*($hcnts{$key}->[6]/($hcnts{$key}->[0]+1e-6)));
}
print "------------------------------------------------------------------------------------------------------------\n";
print sprintf("%20s","FILTER")."\t#SNPs\t#dbSNP\t%dbSNP\tKnown\tNovel\tOverall\t%HM3\t%HM3\n";
print sprintf("%20s","")."\t\t\t\tTs/Tv\tTs/Tv\tTs/Tv\tsens\t/SNP\n";
print "------------------------------------------------------------------------------------------------------------\n";
foreach my $key (sort keys %mcnts) {
    print sprintf("%20s",$key)."\t".($mcnts{$key}->[0])."\t".($mcnts{$key}->[1])."\t".sprintf("%.1lf",$mcnts{$key}->[1]*100/$mcnts{$key}->[0]);
    print ( ($mcnts{$key}->[3] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$mcnts{$key}->[2]/$mcnts{$key}->[3]) );
    print ( ($mcnts{$key}->[5] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$mcnts{$key}->[4]/$mcnts{$key}->[5]) );
    print ( ($mcnts{$key}->[5] + $mcnts{$key}->[3] == 0) ? "\tInf" : sprintf("\t%.2lf",($mcnts{$key}->[4]+$mcnts{$key}->[2])/($mcnts{$key}->[5]+$mcnts{$key}->[3]) ) );
    printf("\t%.3lf",100*($mcnts{$key}->[6]/($nFNR+1e-6)));
    printf("\t%.3lf\n",100*($mcnts{$key}->[6]/($mcnts{$key}->[0]+1e-6)));
}
print "------------------------------------------------------------------------------------------------------------\n";
if ( $passes[0] > 0 ) {
    print sprintf("%20s","PASS")."\t".($passes[0])."\t".($passes[1])."\t".sprintf("%.1lf",$passes[1]*100/$passes[0]);
    print ( ($passes[3] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$passes[2]/$passes[3]) );
    print ( ($passes[5] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$passes[4]/$passes[5]) );
    print ( ($passes[3]+$passes[5] == 0 ) ? "\tInf" : sprintf("\t%.2lf",($passes[2]+$passes[4])/($passes[3]+$passes[5])) );
    printf("\t%.3lf",100*($passes[6]/($nFNR+1e-6)));
    printf("\t%.3lf\n",100*($passes[6]/($passes[0]+1e-6)));
}
if ( $fails[0] > 0 ) {
    print sprintf("%20s","FAIL")."\t".($fails[0])."\t".($fails[1])."\t".sprintf("%.1lf",$fails[1]*100/$fails[0]);
    print ( ($fails[3] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$fails[2]/$fails[3]) );
    print ( ($fails[5] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$fails[4]/$fails[5]) );
    print ( ($fails[3]+$fails[5] == 0 ) ? "\tInf" : sprintf("\t%.2lf",($fails[2]+$fails[4])/($fails[3]+$fails[5])) );
    printf("\t%.3lf",100*($fails[6]/($nFNR+1e-6)));
    printf("\t%.3lf\n",100*($fails[6]/($fails[0]+1e-6)));
}
print sprintf("%20s","TOTAL")."\t".($totals[0])."\t".($totals[1])."\t".sprintf("%.1lf",$totals[1]*100/$totals[0]);
print ( ($totals[3] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$totals[2]/$totals[3]) );
print ( ($totals[5] == 0 ) ? "\tInf" : sprintf("\t%.2lf",$totals[4]/$totals[5]) );
print ( ($totals[3]+$totals[5] == 0 ) ? "\tInf" : sprintf("\t%.2lf",($totals[2]+$totals[4])/($totals[3]+$totals[5])) );
printf("\t%.3lf",100*($totals[6]/($nFNR+1e-6)));
printf("\t%.3lf\n",100*($totals[6]/($totals[0]+1e-6)));
print "------------------------------------------------------------------------------------------------------------\n";
