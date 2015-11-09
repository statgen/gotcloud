#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Cwd;
use FindBin;
use lib "$FindBin::Bin";
use IO::File;

my $man = 0;
my $help = 0;
my $list = "";
my $bgl = "";
my $vcf = "";
my $out = "";
my $chr = "";
my $ignoreFilter = "";
my $bindir = "$FindBin::Bin";
my $bgzip = "$bindir/../bin/bgzip";
my $tabix = "$bindir/../bin/tabix";

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions("help|?" => \$help, 
	   "man" => \$man,
	   "list=s" => \$list,
	   "bgl=s",\$bgl,
	   "vcf=s",\$vcf,
	   "out=s",\$out,
	   "chr=s",\$chr,
	   "ignore-filter",\$ignoreFilter,
    ) || pod2usage(2);

pod2usage(1) if $help;

pod2usage(-verbose => 2) if $man;

unless ( ( $vcf ) && ( $out ) && ( $list ) ) {
    print STDERR "ERROR: Missing required option\n";
    pod2usage(2);
}

die "Cannot open $list for reading\n" unless ( -s $list );
die "Cannot open $vcf for reading\n" unless ( -s $vcf );
die "Cannot open $bgl.1.vcf.gz\n" unless ( -s "$bgl.1.vcf.gz" );

## parse the list file
my %hlists = ();
open(LIST,$list) || die "Cannot open file\n";
while(<LIST>) {
    my ($num,$chrom,$beg,$end) = split;
    if ( defined($hlists{$chrom}) ) {
	next if ( $hlists{$chrom}->[$#{$hlists{$chrom}}]->[2] == $end );
    }
    else {
	$hlists{$chrom} = [];
    }
    print STDERR "Checking $bgl.$num.vcf.gz..\n";
    die "Cannot open $bgl.$num.vcf.gz\n" unless ( -s "$bgl.$num.vcf.gz" );
    push(@{$hlists{$chrom}},[$num,$beg,$end]);
}

my @chrs = $chr ? ($chr) : sort keys %hlists;

foreach my $chr (@chrs) {  
    print STDERR "Ligating chr$chr..\n";

    ## Find out the phase of overlapping segments, with respect to the first file
    my @lists = @{$hlists{$chr}};

    my @curFlips = ();
    my @nextFlips = ();
    my $ninds;
    
    my ($curFH,$curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurFields,$rCurPhases,$rCurIds);
    my ($nextFH,$nextChrom,$nextPos,$nextId,$nextRef,$nextAlt,$nextQual,$nextFilter,$nextInfo,$nextFormat,$rNextFields,$rNextPhases,$rNextIds);
    my @F = ();
    my @ids = ();

    if ( ( $#chrs == 0 ) && ( $out =~ /\.vcf.gz$/ ) ) { open(OUT,"| $bgzip -c > $out") || die "Cannot open file\n"; }
    else { open(OUT,"| $bgzip -c > $out.chr$chr.vcf.gz") || die "Cannot open file\n"; }

    open(VCF,"$tabix -H $vcf |") || die "Cannot open file\n";
    while(<VCF>) {
	print OUT $_;
	if ( /^#CHROM/ ) {
	    @F = split(/[\t\r\n]/);
	    @ids = @F[9..$#F];
	    $ninds = $#ids+1;
	}
    }
    close VCF;
    my $exit = $? >> 8;
    die "ERROR: ligateVcf4.pl, failed to open $vcf, exit code: $exit\n" if $exit;

    if ( $ignoreFilter ) {
	open(VCF,"$tabix $vcf $chr:0 |") || die "Cannot open file\n";
    }
    else {
	open(VCF,"$tabix $vcf $chr:0 | grep -w PASS |") || die "Cannot open file\n";
    }
    @F = split(/[\t\r\n]/,<VCF>);

    for(my $i=0; $i < @lists; ++$i) {
	## print the non-overlapping part of the files first
	#my $beg = ( $i == 0 ) ? 0 : ( ($lists[$i-1]->[2] + $lists[$i]->[1])/ 2 );
	#my $end = ( $i < $#lists ) ? ( ($lists[$i]->[2] + $lists[$i+1]->[2]) / 2 ) : $lists[$i]->[2];

	if ( $i == 0 ) {
	    ($curFH,$curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurFields,$rCurPhases,$rCurIds) = &openVCF("$bgl.".$lists[$i]->[0].".vcf.gz");
	    die "$ninds != ".($#{$rCurIds}+1)."\n" unless ($ninds == $#{$rCurIds} + 1);
	    for(my $j=0; $j < $ninds; ++$j) {
		push(@curFlips,0);
		push(@nextFlips,0);
	    }
	}
	else {
	    $curFH = $nextFH;
	    @curFlips = @nextFlips;	    
	}

	## cache the leading line of next files first
	if ( $i < $#lists ) {
	    ($nextFH,$nextChrom,$nextPos,$nextId,$nextRef,$nextAlt,$nextQual,$nextFilter,$nextInfo,$nextFormat,$rNextFields,$rNextPhases,$rNextIds) = &openVCF("$bgl.".($lists[$i+1]->[0]).".vcf.gz");
	    die "$ninds != ".($#{$rNextIds}+1)."\n" unless ($ninds == $#{$rNextIds} + 1);
	}
	else {
	    $nextFH = undef;
	    $nextPos = undef;
	}

	while( defined($curPos) && ( ( !defined($nextPos) || ( $F[1] < $nextPos ) ) || ( ( $F[1] == $nextPos ) && ( ( $F[3] ne $nextRef ) || ( $F[4] ne $nextAlt ) ) ) ) ) {
	    if ( ( $F[1] == $curPos ) && ( $F[3] eq $curRef ) && ( $F[4] eq $curAlt ) ) {  ## overlaps
		&printVCF(\@F,$curInfo,$rCurFields,$rCurPhases,\@curFlips);
		($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurFields,$rCurPhases) = &iterateVCF($curFH);
	    }
	    else {
		if ( $F[7] eq "." ) { $F[7] = "UNPHASED"; }
		else { $F[7] .= ";UNPHASED"; }
		print OUT join("\t",@F);
		print OUT "\n";
	    }
	    @F = split(/[\t\r\n]/,<VCF>);
	}

	if ( defined($curPos) ) {
	    print STDERR "Overlapping from $curPos:$curRef/$curAlt\n";
	    my @curPhases = ();
	    my @nextPhases = ();
	    my @curFields = ();
	    my @nextFields = ();
	    my @curInfos = ();
	    my @nextInfos = ();
	    my @sites = ();
	    
	    #for(my $j=0; $j < $ninds+$ninds; ++$j) {
	    #    push(@curPhases,[]);
	    #    push(@nextPhases,[]);
	    #}
	    ## read overlapping lines to determine the phases
	    while( defined($nextFH) && defined($curPos) && defined($nextPos) ) {
		die "Marker mismatch: $curPos $curRef $curAlt - $nextPos $nextRef $nextAlt" unless ( ( $curPos == $nextPos ) && ( $curRef eq $nextRef ) && ( $curAlt eq $nextAlt ) );
		push(@sites,[$curPos,$curRef,$curAlt]);
		push(@curInfos,$curInfo);
		push(@nextInfos,$nextInfo);
		push(@curFields,$rCurFields);
		push(@nextFields,$rNextFields);
		push(@curPhases,$rCurPhases);
		push(@nextPhases,$rNextPhases);
		#for(my $j=0; $j < $ninds+$ninds; ++$j) {
		#push(@{$curPhases[$j+$j]},$rCurPhases->[$j+$j]);
		#push(@{$curPhases[$j+$j+1]},$rCurPhases->[$j+$j+1]);
		#push(@{$nextPhases[$j+$j]},$rNextPhases->[$j+$j]);
		#push(@{$nextPhases[$j+$j+1]},$rNextPhases->[$j+$j+1]);
		#}
		($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurFields,$rCurPhases) = &iterateVCF($curFH);	    
		($nextChrom,$nextPos,$nextId,$nextRef,$nextAlt,$nextQual,$nextFilter,$nextInfo,$nextFormat,$rNextFields,$rNextPhases) = &iterateVCF($nextFH);	    
	    }
	    
	    print STDERR "Found ".($#sites+1)." overlapping (phased) variants between chunk ".($lists[$i]->[0])." and ".($lists[$i+1]->[0])."\n";
	    #print STDERR "$sites[0]->[0] $sites[0]->[1] $curPhases[0] $curPhases[1] $nextPhases[0] $nextPhases[1] $curPhases[0]->[0] $curPhases[0]->[1]\n";
	    ## resolve the flips
	    for(my $j=0; $j < $ninds; ++$j) {
		my ($m1,$m2) = &matchPhases(\@curPhases,\@nextPhases,$j+$j,$j+$j+1,$#sites+1);
		if ( $m1 > $m2 ) {
		    $nextFlips[$j] = $curFlips[$j];
		}
		else {
		    $nextFlips[$j] = ( $curFlips[$j] == 0 ? 1 : 0 );
		}
	    }
	    
	    for(my $j=0; $j < @sites; ++$j) {
		while ( !( ( $F[1] == $sites[$j]->[0] ) && ( $F[3] eq $sites[$j]->[1] ) && ( $F[4] eq $sites[$j]->[2] ) ) ) {
		    $F[7] .= ";UNPHASED";
		    print OUT join("\t",@F);
		    print OUT "\n";
		    @F = split(/[\t\r\n]/,<VCF>);		
		}
		
		if ( $j + $j < @sites ) {
		    &printVCF(\@F,$curInfos[$j],$curFields[$j],$curPhases[$j],\@curFlips);
		}
		else {
		    &printVCF(\@F,$nextInfos[$j],$nextFields[$j],$nextPhases[$j],\@nextFlips);
		}
		@F = split(/[\t\r\n]/,<VCF>);
	    }
	    
	    @curFlips = @nextFlips;
	    $curFH = $nextFH;
	    ($curChrom,$curPos,$curId,$curRef,$curAlt,$curQual,$curFilter,$curInfo,$curFormat,$rCurFields,$rCurPhases) = ($nextChrom,$nextPos,$nextId,$nextRef,$nextAlt,$nextQual,$nextFilter,$nextInfo,$nextFormat,$rNextFields,$rNextPhases);
	}
    }

    while ( defined($F[1]) ) {
	$F[7] .= ";UNPHASED";
	print OUT join("\t",@F);
	print OUT "\n";
	@F = split(/[\t\r\n]/,<VCF>);
    }
    close OUT;
}

sub matchPhases {
    my ($ra,$rb,$h1,$h2,$n) = @_;
    my ($m1,$m2) = (0,0);
    for(my $i=0; $i < $n; ++$i) {
	my $a1 = $ra->[$i]->[$h1];
	my $a2 = $ra->[$i]->[$h2];
	my $b1 = $rb->[$i]->[$h1];
	my $b2 = $rb->[$i]->[$h2];
	die "$a1 $a2 $b1 $b2 $i $h1 $h2 $n\n" unless ( defined($a1) && defined($a2) && defined($b1) && defined($b2) );
	++$m1 if ( ( $a1 == $b1 ) && ( $a2 == $b2 ) );
	++$m2 if ( ( $a1 == $b2 ) && ( $a2 == $b1 ) );
    }
    return ($m1,$m2);
}

=item openVCF()

This function opens a VCF(.gz) file and eats all the header lines.

Output:
     $fh - a filehandle to the VCF file, starting at the first line of data
     @header - the output of parseLine() for the header line
     @indids - the IDs of individuals

=cut

sub openVCF {
    my $vcf = shift;
    my $fh;
    if ( $vcf =~ /\.gz$/ ) {
	die "Cannot open $vcf\n" unless ( -s $vcf );
	open($fh,"zcat $vcf|") || die "Cannot open $vcf\n";
    }
    else {
	$fh = new IO::File $vcf, "r" || die "Cannot open $vcf\n";
    }
    print STDERR "Opening $vcf..\n";
    my $line;
    my @indids = ();
    do {
	$line = $fh->getline();
	die "Cannot read a line from $vcf\n" unless ( defined($line) );
	if ( $line =~ /^#CHROM/ ) {
	    my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@ids) = split(/\s+/,$line);
	    @indids = @ids;
	}
	#print $line if ( defined($printHeaderFlag) && ( $printHeaderFlag == 1 ) && ( $line =~ /^#/ ) );
    } while ( $line =~ /^#/ );
    return ($fh,&parseLine($line),\@indids);
}

sub iterateVCF {
    my $fh = shift;
    my $line = $fh->getline();
    return &parseLine($line);
}

=item parseLine()

Parseline takes a line from a vcf and returns ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,\@fields,\@phases).

@phases (length 2N) and @fields (length N) come from the regex /^(\d)\|(\d):(\S+)$/ run against each of the genotypes (length N).

It also adds "AN=(number of haplotypes);AC=(sum of haplotypes)" to the info field.

=cut

sub parseLine {
    my $line = shift;
    return undef unless ( defined($line) );
    my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@genos) = split(/\s+/,$line);
    my @phases = ();
    my @fields = ();
    my ($an,$ac) = (0,0);
    for(my $i=0; $i < @genos; ++$i) {
	my ($g1,$g2,$oth) = ($1,$2,$3) if ( $genos[$i] =~ /^(\d)\|(\d):(\S+)$/ );
	die "Cannot parse '$genos[$i]'" unless ( defined($g1) && defined($g2) && defined($oth));
	push(@phases,$g1);
	push(@phases,$g2);
	push(@fields,$oth);
	$an += 2;
	$ac += ($g1+$g2);
    }
    if ( defined($info) && (!( $info =~ /AC=/ )) ){
	$info = "AC=$ac;AN=$an".($info eq "." ? "" : ";$info");
    }
    return ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,\@fields,\@phases);
}

#	&printVCF(\@F,$curInfo,$rCurGenos,$rCurPhase,\@curFlips);
sub printVCF {
    my ($rAnc,$info,$rFields,$rPhases,$rFlips) = @_;

    print OUT $rAnc->[0];
    for(my $j=1; $j < 7; ++$j) {
	print OUT "\t";
	print OUT $rAnc->[$j];
    }
    $rAnc->[7] =~ s/AC=/RAW_AC=/;
    $rAnc->[7] =~ s/AN=/RAW_AN=/;
    $rAnc->[7] =~ s/AF=/RAW_AF=/;
    if ( $rAnc->[7] eq "." ) {
	print OUT "\t$info";
    }
    else {
	print OUT "\t$info;";
	print OUT $rAnc->[7];
    }
    $rAnc->[8] =~ s/^GT://;
    $rAnc->[8] =~ s/:PL3/:PL/;
    print OUT "\tGT:DS:GP:".$rAnc->[8];

    my $ninds = $#{$rFields}+1;

    for(my $j=0; $j < $ninds; ++$j) {
	print OUT "\t";
	die "Flip does not exist\n" unless (defined($rFlips->[$j]));
	if ( $rFlips->[$j] == 0 ) {
	    print OUT $rPhases->[$j+$j]."|".$rPhases->[$j+$j+1];
	}
	else {
	    print OUT $rPhases->[$j+$j+1]."|".$rPhases->[$j+$j];
	}
	print OUT ":".$rFields->[$j];
	print OUT substr($rAnc->[$j+9],3);
    }
    print OUT "\n";
}

__END__
