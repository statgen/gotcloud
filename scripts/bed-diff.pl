#!/usr/bin/env perl

## per-individual plot should include
## Average-depth across all chip sites
## Individual accuracy

use strict;
use IO::Zlib;
use POSIX qw(exp log pow log10);
use warnings;
use File::Path qw(make_path);
use File::Basename;
use Cwd;
use Cwd 'abs_path';
use FindBin;
use lib "$FindBin::Bin/../bin";
use hyunlib qw(forkExecWait initRef %hszchrs @achrs batchCmd xargsCmd mosixCmd joinps getAbsPath getIntConf loadConf dumpConf setConf getConf ReadConfig parseKeyVal);
use gcGetOptions qw(gcpod2usage gcGetOptions gcstatus);

$_ = abs_path($0);
my($scriptName, $scriptPath) = fileparse($_);
my $scriptDir = abs_path($scriptPath);
my $gotcloudRoot = $scriptDir;
if ($scriptDir =~ /(.*)\/bin/) { $gotcloudRoot = $1;}
elsif ($scriptDir =~ /(.*)\/scripts/) { $gotcloudRoot = $1;}
push @INC,"$gotcloudRoot/bin";                  # Use lib is a BEGIN block and does not work

my $vcf1 = "";
my $vcf2 = "";
my $bfile1 = "";
my $bfile2 = "";
my $out = "";
my $csvExcludeIDs = "";
my $csvIncludeIDs = "";
my $diffFlag = 1;
my $drawFlag = 1;
my $title = "";
my $orderf = "";
my $acUnit = 1;
my $maxAC = 0;
my $auto = "";
my $region = "";
my $noflip = "";
my $minmaj = "";

my @exIDs = ();
my @inIDs = ();

my $result = gcGetOptions(
    "-VCF/PLINK genotype quality evaluation software",
    "--Input Options",
    "bfile1=s",[\$bfile1,"Gold standard genotype PLINK-format binary data typically from arrays"],
    "bfile2=s",[\$bfile2,"Genotype file to be evaluated in PLINK format"],
    "vcf1=s",[\$vcf1,"Gold standard genotype VCF-format binary data typically from arrays"],
    "vcf2=s",[\$vcf2,"Genotype file to be evaluated in VCF format"],
    "--Output Options",
    "out=s",[\$out,"Output file name"],
    "--Difference analysis Options",
    #"diff",[\$diffFlag,"Calculate difference between genotypes"],
    "exIDs=s",[\$csvExcludeIDs,"Comma-separated list of IDs to be excluded for comparisons"],
    "inIDs=s",[\$csvIncludeIDs,"Comma-separated list of IDs to be included for comparisons"],
    "minmaj",[\$minmaj,"Perform analysis based on major-minor alleles rather than ref-alt alleles"],
    "noflip",[\$noflip,"Do not flip genotypes even when flipping increases the concordance"],
    "--Plotting Options",
    #"draw",[\$drawFlag,"Draw results with gnuplot (gnuplot needs to be installed and configured)"],
    #"title=s",[\$title,"Title in the plot"],
    "order=s",[\$orderf,"Order of individuals to be appeared in the plot"],
    "acUnit=i",[\$acUnit,"Unit of allele count to binned together"],
    "maxAC=i",[\$maxAC,"Maximum allele count to show in the plot"],
    "gcRoot=s",[\$gotcloudRoot,"Path to GotCloud"],
    ) || gcpod2usage(2);

unless ( ( $result ) && ( ( $drawFlag ) || ( $diffFlag ) ) ) {
    print STDERR "Error in parsing options\n";
    gcpod2usage(2);
}

unless ( $out ) {
    print STDERR "--out needs to be specified\n";
    gcpod2usage(2);
}

if ( $diffFlag ) {
    # Determine the output directory
    my $outdir = "./";
    if($out =~ /(.*\/)/)
    {
        $outdir = "$1/tmp/";
        system("mkdir -p $outdir") &&
        die "Unable to create directory '$outdir'\n";
    }
    unless ( $bfile1 ) {
	unless ( $vcf1 ) {
	    print STDERR "--vcf1 or --bfile1 needs to be specified\n";
	    gcpod2usage(2);
	}
	$bfile1 = $vcf1;
	$bfile1 =~ s/.*\//$outdir/g;
	my $cmd = "$gotcloudRoot/bin/vcfCooker --write-bed --in-vcf $vcf1 --out $bfile1";
	&forkExecWait($cmd);
    }

    unless ( $bfile2 ) {
	unless ( $vcf2 ) {
	    print STDERR "--vcf2 or --bfile2 needs to be specified\n";
	    gcpod2usage(2);
	}
	$bfile2 = $vcf2;
	$bfile2 =~ s/.*\//$outdir/g;
	my $cmd = "$gotcloudRoot/bin/vcfCooker --write-bed --in-vcf $vcf2 --out $bfile2";
	&forkExecWait($cmd);
    }
}

# if diffFlag is set, try to find out differences in overlapping markers
if ( $diffFlag )  {
    my ( $regionChr, $regionStart, $regionEnd ) = split(/[:\-]/,$region);
    $regionEnd = 1e9 unless defined($regionEnd);
    if ( defined($regionChr) ) {
	$regionChr = 23 if ( $regionChr eq "X" );
	$regionChr = 24 if ( $regionChr eq "Y" );
    }

    if ( -s $csvExcludeIDs ) {
	print STDERR "Reading file $csvExcludeIDs..\n";
	open(IN,$csvExcludeIDs) || die "Cannot open file\n";
	while(<IN>) {
	    chomp;
	    my ($id) = split;
	    push(@exIDs,$id);
	}
	close IN;
    }
    elsif ( length($csvExcludeIDs) > 0 ) {
	@exIDs = split(/,/,$csvExcludeIDs);
    }
    if ( -s $csvIncludeIDs ) {
	print STDERR "Reading file $csvExcludeIDs..\n";
	open(IN,$csvIncludeIDs) || die "Cannot open file\n";
	while(<IN>) {
	    chomp;
	    my ($id) = split;
	    push(@inIDs,$id);
	}
	close IN;
    }
    elsif ( length($csvIncludeIDs) > 0 ) {
	@inIDs = split(/,/,$csvIncludeIDs);
    }

    my ($fh1,$ninds1,$riids1,$rhiids1,$rsnps1) = &openBED($bfile1);
    my ($fh2,$ninds2,$riids2,$rhiids2,$rsnps2) = &openBED($bfile2);
    
    ## build indices for overlapping individuals
    my %hExIDs = ();
    my %hInIDs = ();
    foreach my $exID (@exIDs) {
	$hExIDs{$exID} = 1;
    }
    foreach my $inID (@inIDs) {
	$hInIDs{$inID} = 1;
    }
    my @idx1 = ();
    my @idx2 = ();
    for(my $i=0; $i < $ninds1; ++$i) {

	if ( ( defined($rhiids2->{$riids1->[$i]}) ) && 
	     ( !defined($hExIDs{$riids1->[$i]}) ) && 
	     ( ( $#inIDs < 0 ) || defined($hInIDs{$riids1->[$i]}) )
	    ) {
	    push(@idx1,$rhiids1->{$riids1->[$i]});
	    push(@idx2,$rhiids2->{$riids1->[$i]});
	}
    }
    
    print STDERR "Identified ".($#idx1+1)." overlapping individuals outside the exclusion list\n";
    
# iterate over a hapmap SNP
    open(BOTH,">$out.both") || die "Cannot open file\n";
    open(IND,">$out.ind") || die "Cannot open file\n";
    
    my ($nBoth) = (0);
    
    my @indcnts = ();
    for(my $i=0; $i < @idx1; ++$i) {
	push(@indcnts,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    }

    my $nsnps1 = $#{$rsnps1}+1;
    my $nsnps2 = $#{$rsnps2}+1;

    my $j = 0;
    my ($chrom2,$pos2,$ref2,$alt2) = @{$rsnps2->[0]};
    for(my $i = 0; $i < $nsnps1; ++$i) {
	my ($chrom1,$pos1,$ref1,$alt1) = @{$rsnps1->[$i]};
	## when the SNP position overlaps, order by allele length
	next if ( defined($regionChr) && ( ( $chrom1 ne $regionChr ) || ( $pos1 < $regionStart ) || ( $pos1 > $regionEnd ) ) );
	while ( ( $chrom2 < $chrom1 ) || ( ( $chrom2 eq $chrom1 ) && ( ( $pos2 < $pos1 ) || ( ( $pos2 eq $pos1 ) && ( length($ref1.$alt1) < length ($ref2.$alt2) ) ) ) ) ) {
	#while ( ( $chrom2 ne $chrom1 ) || ( ( $chrom2 eq $chrom1 ) && ( ( $pos2 < $pos1 ) || ( ( $pos2 eq $pos1 ) && ( length($ref1.$alt1) < length ($ref2.$alt2) ) ) ) ) ) {
	    ++$j;
	    last unless defined($rsnps2->[$j]);
	    ($chrom2,$pos2,$ref2,$alt2) = @{$rsnps2->[$j]};   
	}
	if ( ( $chrom1 eq $chrom2 ) && ( $pos1 == $pos2 ) && ( $ref1 eq $ref2 ) && ( $alt1 eq $alt2 ) ) {
	    next if ( ( $chrom1 > 22 ) && ( $auto ) );

	    my @genos1 = &bedGeno($fh1,$ninds1,$i,@idx1);
	    my @genos2 = &bedGeno($fh2,$ninds2,$j,@idx2);

	    my @snpcnts = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	    my @ac1s = (0,0,0,0);
	    for(my $i=0; $i < @genos1; ++$i) {
		++$snpcnts[$genos1[$i]*4+$genos2[$i]];
		++$ac1s[$genos1[$i]];
	    }

	    if ( ($minmaj) && (2*$ac1s[1]+$ac1s[2] < $ac1s[2]+2*$ac1s[3] ) ) {
		# flip genotype if needed
		@snpcnts = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
		for(my $i=0; $i < @genos1; ++$i) {
		    if ( $genos1[$i] == 1 ) {
			$genos1[$i] = 3;
		    }
		    elsif ( $genos1[$i] == 3 ) {
			$genos1[$i] = 1;
		    }
		    ++$snpcnts[$genos1[$i]*4+$genos2[$i]];
		}
	    }
	    
	    if ( ( !$noflip ) && ( $snpcnts[5]+$snpcnts[15] < $snpcnts[7]+$snpcnts[13] ) ) {
		# flip genotype if needed
		@snpcnts = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
		for(my $i=0; $i < @genos2; ++$i) {
		    if ( $genos2[$i] == 1 ) {
			$genos2[$i] = 3;
		    }
		    elsif ( $genos2[$i] == 3 ) {
			$genos2[$i] = 1;
		    }
		    ++$snpcnts[$genos1[$i]*4+$genos2[$i]];
		    ++($indcnts[$i]->[$genos1[$i]*4+$genos2[$i]]) if ( $alt1 eq $alt2 );
		}
	    }
	    else {
		for(my $i=0; $i < @genos1; ++$i) {
		    ++($indcnts[$i]->[$genos1[$i]*4+$genos2[$i]]) if ( $alt1 eq $alt2 );
		}
	    }

	    print BOTH "$chrom1\t$pos1\t.\t$ref1\t$alt1\t.\t.\t.\t".join("\t",@snpcnts)."\n";
	    ++$nBoth;
	}
    }
    
    close BOTH;
    $fh1->close();
    $fh2->close();
    
    for(my $i=0; $i < @indcnts; ++$i) {
	print IND $riids1->[$idx1[$i]];
	print IND "\t";
	print IND join("\t",@{$indcnts[$i]});
	print IND "\n";
    }
    close IND;
}

if ( $drawFlag ) {
    my $prefix = $out;
    my %hCnts = ();
    my @nRefCnts = (0,0,0,0,0,0,0,0,0);
    my @nMajCnts = (0,0,0,0,0,0,0,0,0);
    my $nGenos = 0;
    
    my @orders = ();
    if ( $orderf ) {
	open(IN,$orderf) || die "Cannot open file $orderf\n";
	while(<IN>) {
	    my ($id) = split;
	    push(@orders,$id);
	}
	close IN;
    }
    
    my $nInds;
    open(IN,"$prefix.both") || die "Cannot open file\n";
    while(<IN>) {
	my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info,@n) = split;
	my $nind = $n[0]+$n[1]+$n[2]+$n[3]+$n[4]+$n[5]+$n[6]+$n[7]+$n[8]+$n[9]+$n[10]+$n[11]+$n[12]+$n[13]+$n[14]+$n[15];
	$nInds = $nind unless defined($nInds);
	my $an = 2*($n[5]+$n[6]+$n[7]+$n[9]+$n[10]+$n[11]+$n[13]+$n[14]+$n[15]);
	my $ac = $n[9]+$n[10]+$n[11]+2*($n[13]+$n[14]+$n[15]);
	#my $adjac = ($an > 0) ? sprintf("%.0lf",$ac*$nind*2/$an) : 0;
	next if ( $an == 0 );
	my $adjac = sprintf("%d",int($ac/$acUnit)*$acUnit);
	
	unless(defined($hCnts{$adjac})) {
	    $hCnts{$adjac} = [0,0,0,0,0,0,0,0,0];
	}
	my @q = (0,1,2);
	if ( $ac*2 > $an ) { @q = (2,1,0); }
	
	for(my $i=0; $i < 3; ++$i) {
	    for(my $j=0; $j < 3; ++$j) {
		$hCnts{$adjac}->[$i*3+$j] += $n[($i+1)*4+($j+1)];
		$nGenos += $n[($i+1)*4+($j+1)];
		$nRefCnts[$i*3+$j] += $n[($i+1)*4+($j+1)];
		$nMajCnts[$i*3+$j] += $n[($q[$i]+1)*4+($q[$j]+1)];
	    }
	}
    }
    close IN;
    
    open(DAT,">$prefix.AC.dat") || die "Cannot open file\n";
    my $maxFrac = 0;
    foreach my $ac (sort {$a <=> $b} keys %hCnts) {
	my @fracs = (0,0,0);
	$fracs[0] = ($hCnts{$ac}->[0]+$hCnts{$ac}->[1]+$hCnts{$ac}->[2])/($nRefCnts[0]+$nRefCnts[1]+$nRefCnts[2]+1e-6);
	$fracs[1] = ($hCnts{$ac}->[3]+$hCnts{$ac}->[4]+$hCnts{$ac}->[5])/($nRefCnts[3]+$nRefCnts[4]+$nRefCnts[5]+1e-6);
	$fracs[2] = ($hCnts{$ac}->[6]+$hCnts{$ac}->[7]+$hCnts{$ac}->[8])/($nRefCnts[6]+$nRefCnts[7]+$nRefCnts[8]+1e-6);
	foreach my $frac (@fracs) {
	    $maxFrac = $frac if ( ( $ac > 0 ) && ( $maxFrac < $frac ) );
	}
	print DAT "$ac\t".join("\t",@{$hCnts{$ac}})."\t$nGenos\n";
    }
    close DAT;
    
    my $offset = 1e-5;
    # open(CMD,">$prefix.AC.cmd") || die "Cannot open file\n";
    # print CMD "set terminal postscript eps enhanced dashed dashlength 1.0 linewidth 1.0 size 3.5,3 font 'Calibri,14' fontfile 'calibri.pfb' fontfile 'GillSansMT.pfb' fontfile 'GillSansItalic.pfb'\n";
    # print CMD "set out '$prefix.AC.eps'\n";
    # print CMD "set title '$title - per AC ($nInds)' font 'GillSansMT,16'\n";
    # if ( $maxAC ) {
    #   print CMD "set xrange [0:$maxAC]\n";
    # }
    # else {
    #   print CMD "set xrange [0:2*$nInds]\n";
    # }
    # #print CMD "set yrange [0:1]\n";
    # print CMD "set yrange [$offset:1]\n";
    # print CMD "set y2range [0:".sprintf("%.2lf",2*$maxFrac)."]\n";
    # print CMD "set grid x y\n";
    # print CMD "set logscale y\n";
    # print CMD "set key below box\n";
    # print CMD "set xtics nomirror out\n";
    # print CMD "set ytics 0,0.1 nomirror out\n";
    # print CMD "set y2tics nomirror out\n";
    # print CMD "set xlabel '".($minmaj ? "Minor" : "Non-reference")." allele count (bin size : $acUnit)'\n";
    # #print CMD "set ylabel 'Genotype concordance'\n";
    # print CMD "set ylabel 'Genotype discordance (points)'\n";
    # print CMD "set y2label 'Fraction of genotypes (impulses)'\n";
    # my $xshift = 0.3;
    # print CMD "plot '$prefix.AC.dat' u (\$1-$xshift):((\$2+\$3+\$4)/".($nRefCnts[0]+$nRefCnts[1]+$nRefCnts[2]).") lc rgbcolor 'red' lt 1 lw 1 with impulses notitle axis x1y2, '' u (\$1):((\$5+\$6+\$7)/".($nRefCnts[3]+$nRefCnts[4]+$nRefCnts[5]).") lc rgbcolor 'green' lt 1 lw 1 with impulses notitle axis x1y2, '' u (\$1+$xshift):((\$8+\$9+\$10)/".($nRefCnts[6]+$nRefCnts[7]+$nRefCnts[8]).") lc rgbcolor 'blue' lt 1 lw 1 with impulses notitle axis x1y2, '' u 1:((\$3+\$4)/(\$2+\$3+\$4)+$offset) lc rgbcolor 'red' lt 1 pt 7 ps 0.5 with points title 'HomRef', '' u 1:((\$5+\$7)/(\$5+\$6+\$7)+$offset) lc rgbcolor 'green' lt 1 pt 7 ps 0.5 with points title 'Het', '' u 1:((\$8+\$9)/(\$8+\$9+\$10)+$offset) lc rgbcolor 'blue' lt 1 pt 7 ps 0.5 with points title 'HomAlt'\n"; 
    # #print CMD "plot '$prefix.AC.dat' u (\$1-$xshift):((\$2+\$3+\$4)/".($nRefCnts[0]+$nRefCnts[1]+$nRefCnts[2]).") lc rgbcolor 'red' lt 1 lw 1 with impulses notitle axis x1y2, '' u (\$1):((\$5+\$6+\$7)/".($nRefCnts[3]+$nRefCnts[4]+$nRefCnts[5]).") lc rgbcolor 'green' lt 1 lw 1 with impulses notitle axis x1y2, '' u (\$1+$xshift):((\$8+\$9+\$10)/".($nRefCnts[6]+$nRefCnts[7]+$nRefCnts[8]).") lc rgbcolor 'blue' lt 1 lw 1 with impulses notitle axis x1y2, '' u 1:(\$2/(\$2+\$3+\$4)) lc rgbcolor 'red' lt 1 pt 7 ps 0.5 with points title 'HomRef', '' u 1:(\$6/(\$5+\$6+\$7)) lc rgbcolor 'green' lt 1 pt 7 ps 0.5 with points title 'Het', '' u 1:(\$10/(\$8+\$9+\$10)) lc rgbcolor 'blue' lt 1 pt 7 ps 0.5 with points title 'HomAlt'\n"; 
    # close CMD;
    
    #my $setenv = "export GDFONTPATH=/net/fantasia/home/hmkang/lib/fonts; export GNUPLOT_FONTPATH=/net/fantasia/home/hmkang/lib/fonts; export GNUPLOT_PS_DIR=/net/fantasia/home/hmkang/lib/fonts"; #; export GNUPLOT_PFBTOPFA=pfbtops";
#    my $gnudir = "/net/fantasia/home/hmkang/bin/epacts/share/EPACTS/";
#    my $setenv = "export GDFONTPATH=$gnudir; export GNUPLOT_FONTPATH=$gnudir; export GNUPLOT_PS_DIR=$gnudir"; #; export GNUPLOT_PFBTOPFA=pfbtops";

#     my $cmd = "$setenv; /net/fantasia/home/hmkang/bin/gnuplot $prefix.AC.cmd";
#     print "$cmd\n";
#     print `$cmd`;
    
#     $cmd = "$setenv; /net/fantasia/home/hmkang/bin/epstopdf $prefix.AC.eps";
#     print "$cmd\n";
#     print `$cmd`;
    
#     open(IN,"$prefix.ind") || die "Cannot open file\n";
#     open(DAT,">$prefix.ind.dat") || die "Cannot open file\n";
#     my @totRights = (0,0,0);
#     my @totCnts = (0,0,0);
#     my %hIndDats = ();
#     while(<IN>) {
# 	my ($indid,@n) = split;
# 	my $ngeno = $n[0]+$n[1]+$n[2]+$n[3]+$n[4]+$n[5]+$n[6]+$n[7]+$n[8]+$n[9]+$n[10]+$n[11]+$n[12]+$n[13]+$n[14]+$n[15];
# 	my $nvgeno = ($n[5]+$n[6]+$n[7]+$n[9]+$n[10]+$n[11]+$n[13]+$n[14]+$n[15]);
# 	my @cnts = ($n[5]+$n[6]+$n[7],$n[9]+$n[10]+$n[11],$n[13]+$n[14]+$n[15]);
# 	my @rights = ($n[5],$n[10],$n[15]);
# 	my @wrongs = ($n[6]+$n[7],$n[9]+$n[11],$n[13]+$n[14]);
	
# 	my $outLine = "$indid\t".join("\t",@cnts)."\t".join("\t",@rights)."\t".join("\t",@wrongs)."\t$nvgeno\n";
# 	if ( $#orders < 0 ) {
# 	    print DAT $outLine;
# 	}
# 	else {
# 	    $hIndDats{$indid} = $outLine;
# 	}
	
# 	for(my $i=0; $i < @totRights; ++$i) {
# 	    $totRights[$i] += $rights[$i];
# 	    $totCnts[$i] += $cnts[$i];
# 	}
#     }
#     if ( $#orders >= 0 ) {
# 	foreach my $indid (@orders) {
# 	    if ( defined($hIndDats{$indid}) ) {
# 		print DAT $hIndDats{$indid};
# 	    }
# 	}
#     }
#     close DAT;
    
#     open(CMD,">$prefix.ind.cmd") || die "Cannot open file\n";
#     my $width = sprintf("%.1lf",$nInds*0.04+1);
#     print CMD "set terminal postscript eps enhanced dashed dashlength 1.0 linewidth 1.0 size $width,3 font 'Calibri,12' fontfile 'calibri.pfb' fontfile 'GillSansMT.pfb' fontfile 'GillSansItalic.pfb'\n";
#     print CMD "set out '$prefix.ind.eps'\n";
#     print CMD "set title '$title - per individual ($nInds)' font 'GillSansMT,16'\n";
#     print CMD "set grid x y\n";
#     print CMD "set key below box\n";
#     print CMD "set xtics nomirror out rotate font 'Calibri,9'\n";
# #print CMD "plot '$prefix.ind.dat' u (\$2/\$11):xtic(1) lc rgbcolor 'red' lt 1 lw 7 with impulses notitle axis x1y2, '' u (\$3/\$11) lc rgbcolor 'green' lt 1 lw 7 with impulses notitle axis x1y2, '' u (\$4/\$11) lc rgbcolor 'blue' lt 1 lw 7 with impulses notitle axis x1y2, '' u (\$5/\$2) lc rgbcolor 'red' pt 7 ps 0.7 with points title 'HomRef', '' u (\$6/\$3) lc rgbcolor 'green' pt 7 ps 0.7 with points title 'Het', '' u (\$7/\$4) lc rgbcolor 'blue' pt 7 ps 0.7 with points title 'HomAlt'\n"; 

#     print CMD "set ytics 0.6,0.04 nomirror out\n";
#     print CMD "set y2tics 0,0.1 nomirror out\n";
#     print CMD "set ylabel 'Genotype concordance'\n";
#     print CMD "set y2label 'Fraction of genotypes'\n";
#     print CMD "set yrange [0.6:1]\n";
#     print CMD "set y2range [0:1]\n";
#     print CMD "plot '$prefix.ind.dat' u (\$2/\$11):xtic(1) lc rgbcolor 'red' lt 1 pt 6 ps 0.7 with points notitle axis x1y2, '' u (\$3/\$11) lc rgbcolor 'green' lt 1 pt 6 ps 0.7 with points notitle axis x1y2, '' u (\$4/\$11) lc rgbcolor 'blue' lt 1 pt 6 ps 0.7 with points notitle axis x1y2, '' u (\$5/\$2) lc rgbcolor 'red' pt 7 ps 0.7 with points title 'HomRef', '' u (\$6/\$3) lc rgbcolor 'green' pt 7 ps 0.7 with points title 'Het', '' u (\$7/\$4) lc rgbcolor 'blue' pt 7 ps 0.7 with points title 'HomAlt'\n"; 
#     close CMD;
    
#     $cmd = "$setenv; /net/fantasia/home/hmkang/bin/gnuplot $prefix.ind.cmd";
#     print "$cmd\n";
#     print `$cmd`;
    
#     $cmd = "$setenv; /net/fantasia/home/hmkang/bin/epstopdf $prefix.ind.eps";
#     print "$cmd\n";
#     print `$cmd`;

    open(OUT,">$prefix.summary") || die "Cannot open file\n";
    print OUT "OVERALL:\t".($nRefCnts[0]+$nRefCnts[4]+$nRefCnts[8])."\t".($nRefCnts[0]+$nRefCnts[1]+$nRefCnts[2]+$nRefCnts[3]+$nRefCnts[4]+$nRefCnts[5]+$nRefCnts[6]+$nRefCnts[7]+$nRefCnts[8])."\t".sprintf("%.4lf",($nRefCnts[0]+$nRefCnts[4]+$nRefCnts[8])/($nRefCnts[0]+$nRefCnts[1]+$nRefCnts[2]+$nRefCnts[3]+$nRefCnts[4]+$nRefCnts[5]+$nRefCnts[6]+$nRefCnts[7]+$nRefCnts[8]))."\n";
    print OUT "NREF-EITHER:\t".($nRefCnts[4]+$nRefCnts[8])."\t".($nRefCnts[1]+$nRefCnts[2]+$nRefCnts[3]+$nRefCnts[4]+$nRefCnts[5]+$nRefCnts[6]+$nRefCnts[7]+$nRefCnts[8])."\t".sprintf("%.4lf",($nRefCnts[4]+$nRefCnts[8])/($nRefCnts[1]+$nRefCnts[2]+$nRefCnts[3]+$nRefCnts[4]+$nRefCnts[5]+$nRefCnts[6]+$nRefCnts[7]+$nRefCnts[8]))."\n";
    print OUT "NMAJ-EITHER:\t".($nMajCnts[4]+$nMajCnts[8])."\t".($nMajCnts[1]+$nMajCnts[2]+$nMajCnts[3]+$nMajCnts[4]+$nMajCnts[5]+$nMajCnts[6]+$nMajCnts[7]+$nMajCnts[8])."\t".sprintf("%.4lf",($nMajCnts[4]+$nMajCnts[8])/($nMajCnts[1]+$nMajCnts[2]+$nMajCnts[3]+$nMajCnts[4]+$nMajCnts[5]+$nMajCnts[6]+$nMajCnts[7]+$nMajCnts[8]))."\n";
    print OUT "\n";
    print OUT "HOMREF:\t$nRefCnts[0]\t$nRefCnts[1]\t$nRefCnts[2]\t".sprintf("%.4lf",$nRefCnts[0]/($nRefCnts[0]+$nRefCnts[1]+$nRefCnts[2]))."\n";
    print OUT "HET:\t$nRefCnts[3]\t$nRefCnts[4]\t$nRefCnts[5]\t".sprintf("%.4lf",$nRefCnts[4]/($nRefCnts[3]+$nRefCnts[4]+$nRefCnts[5]))."\n";
    print OUT "HOMALT:\t$nRefCnts[6]\t$nRefCnts[7]\t$nRefCnts[8]\t".sprintf("%.4lf",$nRefCnts[8]/($nRefCnts[6]+$nRefCnts[7]+$nRefCnts[8]))."\n";
    print OUT "\n";
    print OUT "HOMMAJ:\t$nMajCnts[0]\t$nMajCnts[1]\t$nMajCnts[2]\t".sprintf("%.4lf",$nMajCnts[0]/($nMajCnts[0]+$nMajCnts[1]+$nMajCnts[2]))."\n";
    print OUT "HET:\t$nMajCnts[3]\t$nMajCnts[4]\t$nMajCnts[5]\t".sprintf("%.4lf",$nMajCnts[4]/($nMajCnts[3]+$nMajCnts[4]+$nMajCnts[5]))."\n";
    print OUT "HOMMIN:\t$nMajCnts[6]\t$nMajCnts[7]\t$nMajCnts[8]\t".sprintf("%.4lf",$nMajCnts[8]/($nMajCnts[6]+$nMajCnts[7]+$nMajCnts[8]))."\n";
}

sub openBED {
    my $bfile = $_[0];
    my @iids = ();
    my %hiids = ();
    my @snps = ();
    my ($fbp,$a1,$a2); 

    open(FAM,"$bfile.fam") || die "Cannot open $bfile.fam\n";
    for(my $i=0; <FAM>; ++$i) {
	my ($famid,$indid,$fatid,$motid,$sex,$pheno) = split;
	push(@iids,$indid);
	die "$indid is no unique" if (defined($hiids{$indid}));
	$hiids{$indid} = $i;
    }
    close FAM;

    open(BIM,"$bfile.bim") || die "Cannot open $bfile.bim\n";
    while(<BIM>) {
	my ($chr,$id,$cM,$bp,$a1,$a2) = split;
	push(@snps,[$chr,$bp,$a1,$a2]);
    }
    close BIM;

    my $fh = new IO::File;
    $fh->open("$bfile.bed","r") || die "Cannot open $bfile.bed\n";
    # check out the magic numbers
    read($fh, my $buf, 3);
    my @bedFirstBytes = unpack('C*',$buf);
    my @bedMagicNumbers = (0x6c,0x1b,0x01);
    for(my $i=0; $i < @bedMagicNumbers; ++$i) {
        die "BED magic numbers do not match at byte $i\n" unless ( $bedFirstBytes[$i] == $bedMagicNumbers[$i] );
    }
    return($fh, $#iids+1, \@iids, \%hiids, \@snps); 
}

sub bedGeno {
    my ($fhBED,$ninds,$isnp,@idx) = @_;
    my $bytesPerRecord = int(($ninds+3)/4);
    seek($fhBED,($isnp*$bytesPerRecord)+3,0);
    my @genos = ();
    read($fhBED,my $buf,$bytesPerRecord);
    my @bedBits = split(//,unpack('b*',$buf));
    if ( $#idx < 0 ) {
	for(my $i=0; $i < $ninds; ++$i) {
	    push(@idx,1);
	}
    }
    else {
	for my $j (@idx) {
	    # 0-REFHOM 1-HET 2-MISSING 3-ALTHOM
	    my $g = 2*$bedBits[$j*2]+$bedBits[$j*2+1];
	    if ( $g == 2 ) { $g = 0; }
	    elsif ( $g < 2 ) { ++$g; }
	    push(@genos,$g);
	}
    }
    return(@genos);
}
