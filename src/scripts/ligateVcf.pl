#!/usr/bin/perl -w

use strict;
use IO::File;
use IO::Zlib;
use Getopt::Long;

# Usage : perl mpipeline-vcf-ligate.pl [split.1.vcf] [split.2.vcf] .. [split.n.vcf] > [ligated.vcf]

# ligate VCF by matching phase at overlapping haplotypes
# - phase is determined by minimizing the sum of hamming distance
# - genotype information of overlapping SNPs are resolved by selecting
#   1st/2nd half of the SNP info from former/latter file

# VCFs must be ordered by genomic location.
my @vcfs = @ARGV;

# First file - print the header, print lines no matter what, decide whether to flip the phase or not for each individual
# 1. Read all of the first file
# 2. Read overlapping fraction of the second file
# 3. Write (n-o) lines
# 4. Determine phase using pair of o lines
# 5. Write first o/2 lines
# 6. Write second o/2 lines
# 7. Read the rest of the second file
# 8. Read overlapping fraction of third file ...
# ... and so on ...

sub openVCF {
    my $vcf = shift;
    my $printHeaderFlag = shift;
    my $fh;
    if ( $vcf =~ /\.gz$/ ) {
	$fh = new IO::Zlib;
	$fh->open($vcf, "rb") || die "Cannot open $vcf\n";
    }
    else {
	$fh = new IO::File $vcf, "r" || die "Cannot open $vcf\n";
    }
    print STDERR "Opening $vcf..\n";
    my $line;
    my @indids = ();
    do {
	$line = $fh->getline();
	if ( $line =~ /^#CHROM/ ) {
	    my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@ids) = split(/\s+/,$line);
	    @indids = @ids;
	}
	print $line if ( defined($printHeaderFlag) && ( $printHeaderFlag == 1 ) && ( $line =~ /^#/ ) );
    } while ( $line =~ /^#/ );
    my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@genos) = split(/\s+/,$line);    
    return ($fh,$chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,\@genos,\@indids);
}

sub iterateVCF {
    my $fh = shift;
    my $line = $fh->getline();
    my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@genos) = split(/\s+/,$line) if defined($line);
    return ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,\@genos);
}

sub flipGT {
    $_ = shift;
    if ( /^([012])\|([012]):(\S+)$/ ) {
	return "$2|$1:$3";
    }
    else {
	die "flipGT() : Cannot parse $_\n";
    }
}

sub printVCF {
    my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,$rGenos,$rFlips,$ninds) = @_;
    print "$chrom\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
    for(my $j=0; $j < $ninds; ++$j) {
	print "\t";

	if ( $rFlips->[$j] == 0 ) {
	    print $rGenos->[$j];
	}
	else {
	    print &flipGT($rGenos->[$j]);
	}
    }
    print "\n";
}

sub countMatches {
    my ($geno1,$geno2) = @_;
    my ($m1,$m2) = (0,0);
    if ( $geno1 =~ /^([012])\|([012]):(\S+)$/ ) {
	my ($a1,$a2) = ($1,$2);
	if ( $geno2 =~ /^([012])\|([012]):(\S+)$/ ) {
	    my ($b1,$b2) = ($1,$2);
	    if ( ( $a1 == $b1 ) && ( $a2 == $b2 ) ) {
		++$m1;
	    }
	    if ( ( $a1 == $b2 ) && ( $a2 == $b1 ) ) {
		++$m2;
	    }
#	    die "$geno1\t$geno2\t$a1\t$a2\t$b1\t$b2\n";
	}
	else {
	    die "countMatches() : Cannot parse $geno2\n";
	}
    }
    else {
	die "counMathces() : Cannot parse $geno1\n";
    }
    return ($m1,$m2);
}

#my ($curFH, $nextFH);
my @curFlips = ();
my @nextFlips = ();
my $ninds;

my ($curFH,$curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos,$rCurIds);
my ($nextFH,$nextChrom,$nextPos,$nextId,$nextRef,$nextAlt,$nextQual,$nextFilter,$nextInfo,$nextFormat,$rNextGenos,$rNextIds);

for(my $i=0; $i < @vcfs; ++$i) {
    if ( $i == 0 ) {
	($curFH,$curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos,$rCurIds) = &openVCF($vcfs[$i],1);
	$ninds = $#{$rCurIds} + 1;
	for(my $j=0; $j < $ninds; ++$j) {
	    push(@curFlips,0);
	}
    }
    else {
	#print STDERR "Switching handles.. - $curChrom $curPos $curId\n";
	$curFH = $nextFH;
	@curFlips = @nextFlips;
    }

    if ( $i < $#vcfs ) {
	($nextFH,$nextChrom,$nextPos,$nextId,$nextRef,$nextAlt,$nextQual,$nextFilter,$nextInfo,$nextFormat,$rNextGenos,$rNextIds) = &openVCF($vcfs[$i+1]);
	die "Ligated VCFs must be in the same chromosome\n" unless ( $curChrom eq $nextChrom );
	die "# of individuals differ between VCF files\n" unless ($ninds == $#{$rNextIds}+1);

	# print non-overlapping part of the first file
	do {
	    &printVCF($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos,\@curFlips,$ninds);
	    ($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos) = &iterateVCF($curFH);
	} while ( defined($curPos) && ( $curPos < $nextPos ) ) ;

	if ( defined($curPos) ) {
	    # determine best phase
	    my @matches = ();
	    for(my $j=0; $j < $ninds; ++$j) {
		push(@matches,0);
		push(@matches,0);
	    }
	    
	    # read until the end of the first file
	    my @curLines = ([$curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos]);
	    my @nextLines = ([$nextChrom,$nextPos,$nextId,$nextRef,$nextAlt,$nextQual,$nextFilter,$nextInfo,$nextFormat,$rNextGenos]);
	    my $nLines = 1;
	    do {
		if ( $curPos ne $nextPos ) {
		    die "The overlapping marker sets are not identical\n";
		}
		else {
		    for(my $j=0; $j < $ninds; ++$j) {
#		    print STDERR "$j\t".join("\t",$nextLines[$nLines-1]->[9]->[$j])."\n";
			die unless defined($nextLines[$nLines-1]->[9]->[$j]);
			die unless defined($curLines[$nLines-1]->[9]->[$j]);
			my ($m1,$m2) = &countMatches($curLines[$nLines-1]->[9]->[$j],$nextLines[$nLines-1]->[9]->[$j]);
			$matches[$j*2] += $m1;
			$matches[$j*2+1] += $m2;
		    }
		    
		    my @curLine = &iterateVCF($curFH);
		    my @nextLine = &iterateVCF($nextFH);
		    push(@curLines,\@curLine);
		    push(@nextLines,\@nextLine);
		    ++$nLines;
		}
	    } while (defined($curLines[$nLines-1]->[0]));
	    
	    #
	    #print STDERR join(" ",@matches)."\n";
	    #die;
	    
	    # resolve the flips
	    print STDERR "Found ".($nLines-1)." overlapping SNPs between consecutive pair of VCFs\n";
	    for(my $j=0; $j < $ninds; ++$j) {
		#print STDERR "$j\t$matches[$j*2]\t$matches[$j*2+1]\n";
		if ( $matches[$j*2] > $matches[$j*2+1] ) {
		    $nextFlips[$j] = ($curFlips[$j] == 0) ? 0 : 1;
		}
		else {
		    $nextFlips[$j] = ($curFlips[$j] == 0) ? 1 : 0;
		}
	    }
	    
	    for(my $j=0; $j < $nLines-1; ++$j) {
		#print STDERR "$j\n";
		if ( $j*2 < $nLines ) {
		    &printVCF(@{$curLines[$j]},\@curFlips,$ninds);
		}
		else {
		    &printVCF(@{$nextLines[$j]},\@nextFlips,$ninds);
		}
	    }
	    ($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos) = @{$nextLines[$nLines-1]};
	}
	else {
	    print STDERR "No overlapping SNPs found between $vcfs[$i] and $vcfs[$i+1]. The phase between the two files may not be correctly ligated\n";
	    ($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos) = ($nextChrom,$nextPos,$nextId,$nextRef,$nextAlt,$nextQual,$nextFilter,$nextInfo,$nextFormat,$rNextGenos);
	}
	#die "$curChrom $curPos\n";
    }
    else {
	do {
	    &printVCF($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos,\@curFlips,$ninds);
	    ($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurGenos) = &iterateVCF($curFH);
	} while ( defined($curPos) );
    }
}
