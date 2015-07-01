package hyunlib;
use strict;
use threads;
use threads::shared;
use base qw/Exporter/;
use FileHandle;
use Cwd qw(realpath abs_path getcwd);
use File::Basename qw( dirname );

my $module_dir = dirname(realpath(__FILE__));

## Variables and methods shared across the package
our @EXPORT = qw(%hszchrs @achrs);
our @EXPORT_OK = qw(loadGTF writeGTF readFasta getCpGs initRef getDegeneracies readCDS loadIlluBpm loadIlluIdat forkExecWait autoPod zopen wopen tofpos fromfpos reverseComplement reverseComplementIUPAC iupacCompatible batchCmd sortedBedInsert sortedBedPush sortedBedMerge sortedBedInvert sortedBedSize sortedBedPrint xargsCmd mosixCmd joinps makeMake getAbsPath getIntConf loadConf dumpConf setConf getConf ReadConfig parseKeyVal);

my $binzcat = "zcat";
my $binbgzip = "$module_dir/bgzip";
my $bintabix = "$module_dir/tabix";
my $binruncluster = "$module_dir/../scripts/runcluster.pl";

my %codon1 = (TTT=>"F", TTC=>"F", TCT=>"S", TCC=>"S", TAT=>"Y", TAC=>"Y", TGT=>"C", TGC=>"C", TTA=>"L", TCA=>"S", TAA=>"*", TGA=>"*", TTG=>"L", TCG=>"S", TAG=>"*", TGG=>"W", CTT=>"L", CTC=>"L", CCT=>"P", CCC=>"P", CAT=>"H", CAC=>"H", CGT=>"R", CGC=>"R", CTA=>"L", CTG=>"L", CCA=>"P", CCG=>"P", CAA=>"Q", CAG=>"Q", CGA=>"R", CGG=>"R", ATT=>"I", ATC=>"I", ACT=>"T", ACC=>"T", AAT=>"N", AAC=>"N", AGT=>"S", AGC=>"S", ATA=>"I", ACA=>"T", AAA=>"K", AGA=>"R", ATG=>"M", ACG=>"T", AAG=>"K", AGG=>"R", GTT=>"V", GTC=>"V", GCT=>"A", GCC=>"A", GAT=>"D", GAC=>"D", GGT=>"G", GGC=>"G", GTA=>"V", GTG=>"V", GCA=>"A", GCG=>"A", GAA=>"E", GAG=>"E", GGA=>"G", GGG=>"G");
my %idatFieldCodes = (1000 => "nSNPsRead", 102 => "IlluminaID", 103 => "SD", 104 => "Mean", 107 => "NBeads", 200 => "MidBlock", 300 => "RunInfo", 400 => "RedGreen", 401 => "Manifest", 402 => "Barcode", 403 => "ChipType", 404 => "Stripe", 405 => "Unknown405", 406 => "SampleID", 407 => "Unknown407", 408 => "Plate", 409 => "Well", 410 => "Unknown410", 510 => "Unknown510");
my %iupacNuc = (AA=>1, CC=>1, GG=>1, TT=>1, RA=>1, RG=>1, YC=>1, YT=>1, SG=>1, SC=>1, WA=>1, WT=>1, KG=>1, KT=>1, MA=>1, MC=>1, BC=>1, BG=>1, BT=>1, DA=>1, DG=>1, DT=>1, HA=>1, HC=>1, HT=>1, VA=>1, VC=>1, VG=>1, NA=>1, NC=>1, NG=>1, NT=>1);
our %hszchrs = ();
our @achrs = ();
my %hchrs = ();

BEGIN {
## Variables below are based on GRCh37
    my @chrs = (1..22,"X","Y","MT");

    for(my $i=0; $i < @chrs; ++$i) {
	$hchrs{$chrs[$i]} = $i;
	$chrs[$i] = "M" if ( $chrs[$i] eq "MT" );
	$hchrs{"chr$chrs[$i]"} = $i;
    }

    #%codon1 = (TTT=>"F", TTC=>"F", TCT=>"S", TCC=>"S", TAT=>"Y", TAC=>"Y", TGT=>"C", TGC=>"C", TTA=>"L", TCA=>"S", TAA=>"*", TGA=>"*", TTG=>"L", TCG=>"S", TAG=>"*", TGG=>"W", CTT=>"L", CTC=>"L", CCT=>"P", CCC=>"P", CAT=>"H", CAC=>"H", CGT=>"R", CGC=>"R", CTA=>"L", CTG=>"L", CCA=>"P", CCG=>"P", CAA=>"Q", CAG=>"Q", CGA=>"R", CGG=>"R", ATT=>"I", ATC=>"I", ACT=>"T", ACC=>"T", AAT=>"N", AAC=>"N", AGT=>"S", AGC=>"S", ATA=>"I", ACA=>"T", AAA=>"K", AGA=>"R", ATG=>"M", ACG=>"T", AAG=>"K", AGG=>"R", GTT=>"V", GTC=>"V", GCT=>"A", GCC=>"A", GAT=>"D", GAC=>"D", GGT=>"G", GGC=>"G", GTA=>"V", GTG=>"V", GCA=>"A", GCG=>"A", GAA=>"E", GAG=>"E", GGA=>"G", GGG=>"G");

    #%idatFieldCodes = (1000 => "nSNPsRead", 102 => "IlluminaID", 103 => "SD", 104 => "Mean", 107 => "NBeads", 200 => "MidBlock", 300 => "RunInfo", 400 => "RedGreen", 401 => "Manifest", 402 => "Barcode", 403 => "ChipType", 404 => "Stripe", 405 => "Unknown405", 406 => "SampleID", 407 => "Unknown407", 408 => "Plate", 409 => "Well", 410 => "Unknown410", 510 => "Unknown510");
}

sub reverseComplement {
    my $seq = shift;
    $seq =~ tr/ACGT/TGCA/;
    return (reverse($seq));
}

sub reverseComplementIUPAC {
    my $seq = shift;
    $seq =~ tr/ACGTRYSWKMBDHVN/TGCAYRSWMKVHDBN/;
    return (reverse($seq));
}

sub readCDS {
    my ($frame,$chr,@icds) = @_;
    my $seq = "";
    foreach my $icd (@icds) {
	my ($beg,$end) = split(/-/,$icd);
	$seq .= &readFasta($chr,$beg,$end);
    }
    if ( $frame eq "+" ) {
	return ($seq);
    }
    else {
	return &reverseComplement($seq);
    }
}

sub getDegeneracies {
    my ($frame,$chr,@icds) = @_;
    my $seq = &readCDS($frame,$chr,@icds);
    $seq = &reverseComplement($seq) if ( $frame eq "-" );
    my $len = length($seq);
    my @degs = ();

    for(my $i=0; $i < $len; $i += 3) {
	my $wt3 = substr($seq,$i,3);
	my $wta = $codon1{$wt3};

	#die "**$wt3\n**$wta\n";

	unless (defined($wta)) {
	    push(@degs,-1,-1,-1);
	    next;
	}
	for(my $j=0; $j < 3; ++$j) {
	    my $vt3 = $wt3;
	    my $deg = 0;
	    foreach my $nt ("A","C","G","T") {
		substr($vt3,$j,1) = $nt;
		if ( $wta eq $codon1{$vt3} ) {
		    ++$deg;
		}
	    }
	    push(@degs,$deg);
	}
    }
    @degs = reverse(@degs) if ( $frame eq "-" );
    return (\@degs);
}

sub getCpGs {
    my ($chr,$beg,$end) = @_;
    $end = $beg unless (defined($end));
    my @seqs = split(//,uc(&readFasta($chr,$beg-1,$end+1)));
    my @cpgs = ();
    for(my $i=1; $i < $#seqs; ++$i) {
	if ( ( ( $seqs[$i] eq "C" ) && ( $seqs[$i+1] eq "G" ) ) ||
	     ( ( $seqs[$i-1] eq "C" ) && ( $seqs[$i] eq "G" ) ) ) {
	    push(@cpgs,1);
	}
	elsif ( $seqs[$i] =~ /^[ACGT]$/ ) {
	    push(@cpgs,0);
	}
	else {
	    push(@cpgs,-1);
	}
    }
    return (\@cpgs);
}

sub initRef {
    my $ref = shift;

    unless ( %hszchrs ) {
	$ref = "/data/local/ref/karma.ref/human.g1k.v37.fa" unless ( defined($ref) );
	open(IN,"$ref.fai") || die "Cannot open file $ref.fai\n";
	my $cumbase = 0;
	@achrs = ();
	for(my $nchr=0; <IN>; ++$nchr) {
	    my ($chrom,$base,$startbyte,$basesperline,$bytesperline) = split;
	    $hszchrs{$chrom} = [$startbyte,$basesperline,$bytesperline,$base,$nchr,$cumbase,$cumbase+$base];
	    push(@achrs,$chrom);
	    $cumbase += $base;
	}
	close IN;
	
	open(FASTA,$ref) || die "Cannot open file $ref\n";
    }
}

sub readFasta {
    my ($chr,$beg,$end,$ref) = @_;

    &initRef($ref) unless ( %hszchrs );

    $chr =~ s/^chr//;
    $chr = "MT" if ( ( $chr eq "M" ) && ( defined($hszchrs{"MT"}) ) );
    my ($startbyte,$basesperline,$bytesperline) = @{$hszchrs{$chr}};
    #my $byteoffset = ($startbyte + int($beg/$basesperline)*$bytesperline + ( $beg % $basesperline ) - 1 );
    my $byteoffset = ($startbyte + int(($beg-1)/$basesperline)*$bytesperline + ( ( $beg - 1 ) % $basesperline ) );
    seek(FASTA,$byteoffset,0);
    my $pos = 0;
    my $bp = $beg;
    my $seq = "";
    while( $bp <= $end ) {
	my $line = <FASTA>;
	chomp $line;
	my $l = length($line);
	if ( $bp + $l <= $end ) {
	    $seq .= $line;
	    $bp += $l;
	}
	else {
	    $seq .= substr($line,0,$end-$bp+1);
	    $bp = $end+1;
	}
    }
    return ($seq);
 }

sub compareIntervals {
    my ($a,$b) = @_;
    my ($beg1,$end1) = split(/\-/,$a);
    my ($beg2,$end2) = split(/\-/,$b);
    my $begcmp = ($beg1 <=> $beg2);
    if ( $begcmp == 0 ) { return ( $end1 <=> $end2 ); }
    else { return $begcmp; }
}

sub compareChrPos {
    my ($key1,$key2,$rhg) = @_;
    my ($chr1,$beg1,$end1) = @{$rhg->{$key1}};
    my ($chr2,$beg2,$end2) = @{$rhg->{$key2}};

    die "Cannot find $key1\n" unless ( defined($beg1) );
    die "Cannot find $key2\n" unless ( defined($beg2) );

    my $chrcmp = $hchrs{$chr1} <=> $hchrs{$chr2};
    if ( $chrcmp == 0 ) {
	my $begcmp = ($beg1 <=> $beg2);
	if ( $begcmp == 0 ) { return ( $end1 <=> $end2 ); }
	else { return $begcmp; }
    }
    else { return $chrcmp; }
}

sub comparePos {
    my ($key1,$key2,$rht) = @_;
    my ($beg1,$end1) = @{$rht->{$key1}}[0..1];
    my ($beg2,$end2) = @{$rht->{$key2}}[0..1];
    my $begcmp = ($beg1 <=> $beg2);
    if ( $begcmp == 0 ) { return ( $end1 <=> $end2 ); }
    else { return $begcmp; }
}

sub runCmd {
    my $cmd = shift;
    print "$cmd\n";
    print `$cmd`;
}

sub writeGTF {
    my ($outf,$rhg,$rht) = @_;

    my %hg = %{$rhg};
    my %ht = %{$rht};

    ## sort by the starting points
    my @gkeys = sort { &compareChrPos($a,$b,$rhg) } keys (%hg);

    my %hgenes = ();
    open(OUT,"| $binbgzip -c > $outf.genes.gz") || die "Cannot open file\n";
    print OUT "#CHROM\tBEG\tEND\tID\tNAME\tFRAME\tTRANSCRIPTS\n";
    foreach my $key (@gkeys) {
	my @F = @{$hg{$key}};
	my @G = @{$F[7]};
	print OUT join("\t",@F[0..5],@G)."\n";
	foreach my $g (@G) {
	    $hgenes{$g} = $key;
	}
    }
    close OUT;
    &runCmd("$bintabix -pvcf $outf.genes.gz");

    ## sort by the starting points
    my @tkeys = sort { &compareChrPos($a,$b,$rht) } keys (%ht);
    open(OUT,"| $binbgzip -c > $outf.transcripts.gz") || die "Cannot open file\n";
    print OUT "#CHROM\tBEG\tEND\tGENE\tTRANSCRIPT\tFRAME\tEXON\tCDS\tSTART\tSTOP\tUTR\n";
    foreach my $key (@tkeys) {
	my @F = @{$ht{$key}};
	print OUT join("\t",@F[0..2]);
	print OUT "\t";
	print OUT join("\t",$hgenes{$key},$key);
	print OUT "\t";
	print OUT $F[3];
	print OUT "\t";
	print OUT ($#{$F[4]} < 0) ? "." : join(",",sort { &compareIntervals($a,$b) } @{$F[4]});
	print OUT "\t";
	print OUT ($#{$F[5]} < 0) ? "." : join(",",sort { &compareIntervals($a,$b) } @{$F[5]});
	print OUT "\t";
	print OUT ($#{$F[6]} < 0) ? "." : join(",",sort { &compareIntervals($a,$b) } @{$F[6]});
	print OUT "\t";
	print OUT ($#{$F[7]} < 0) ? "." : join(",",sort { &compareIntervals($a,$b) } @{$F[7]});
	print OUT "\t";
	print OUT ($#{$F[8]} < 0) ? "." : join(",",sort { &compareIntervals($a,$b) } @{$F[8]});
	print OUT "\n";
    }
    close OUT;
    &runCmd("$bintabix -pvcf $outf.transcripts.gz");
}

sub loadGTF {
    ## [genename, start, end, transcript_id, index_transcript
    ##     [transcript1, start, end,
    ##        [ [exon1_start, exon1_end], [exon2_start, exon2_end], ... ], 
    ##        [ [cds1_start, cds1_end], ..], [cds1_start, cds_end], ... ],
    ##        [ [start_codon1_start, start_codon1_end] ],
    ##        [ [stop_codon1_start, stop_codon1_end] ],
    ##        [ [utr1_start, utr1_end,]... ],
    ##     [transcript2, 

    my %hg = ();
    my %ht = ();

    my $gtf = shift;
    if ( $gtf =~ /\.gz$/ ) {
	die "Cannot open $gtf\n" unless ( -s $gtf );
	open(IN,"$binzcat $gtf|") || die "Cannot open file\n";
    }
    else {
	open(IN,$gtf) || die "Cannot open file\n";
    }
    while(<IN>) {
	next if ( /^#/ );
	print STDERR "Processing $. lines..\n" if ( $. % 10000 == 0 );
	my ($chr,$src,$feature,$beg,$end,$score,$frame,$phase,$attributes,$comments) = split(/[\t\r\n]/);
	my @attrs = split(/;/,$attributes);
	my %hvals = ();
	for(my $i=0; $i < @attrs; ++$i) {
	    $attrs[$i] =~ s/^\s+//;
	    my ($key,$val,@dummies) = split(/\s+/,$attrs[$i]);
	    die "Cannot parse --$attrs[$i]--\n" if ( $#dummies >= 0 );
	    $val =~ s/^"//;
	    $val =~ s/"$//;
	    $hvals{$key} = $val;
	}

	if ( $feature eq "gene" ) {
	    my $gid = $hvals{"gene_id"};
	    my $tid = $hvals{"transcript_id"};
	    my $name = $hvals{"gene_name"};
	    $hg{$gid} = [$chr,$beg,$end,$gid,$name,$frame,$tid,[]];
	}
	elsif ( $feature eq "transcript" ) {
	    my $gid = $hvals{"gene_id"};
	    my $tid = $hvals{"transcript_id"};
	    die "Cannot find gene $gid\n" unless ( defined($hg{$gid}) );
	    push(@{$hg{$gid}->[7]},$tid);
	    $ht{$tid} = [ $chr, $beg, $end, $frame, [], [], [], [], [] ];

	}
	elsif ( $feature eq "exon" ) {
	    my $tid = $hvals{"transcript_id"};
	    die "Cannot find transcript $tid\n" unless ( defined($ht{$tid}) );
	    push(@{$ht{$tid}->[4]},"$beg-$end");
	}
	elsif ( $feature eq "CDS" ) {
	    my $tid = $hvals{"transcript_id"};
	    die "Cannot find transcript $tid\n" unless ( defined($ht{$tid}) );
	    push(@{$ht{$tid}->[5]},"$beg-$end-$phase");
	}
	elsif ( $feature eq "start_codon" ) {
	    my $tid = $hvals{"transcript_id"};
	    die "Cannot find transcript $tid\n" unless ( defined($ht{$tid}) );
	    push(@{$ht{$tid}->[6]},"$beg-$end");
	}
	elsif ( $feature eq "stop_codon" ) {
	    my $tid = $hvals{"transcript_id"};
	    die "Cannot find transcript $tid\n" unless ( defined($ht{$tid}) );
	    push(@{$ht{$tid}->[7]},"$beg-$end");
	}	
	elsif ( $feature eq "UTR" ) {
	    my $tid = $hvals{"transcript_id"};
	    die "Cannot find transcript $tid\n" unless ( defined($ht{$tid}) );
	    push(@{$ht{$tid}->[8]},"$beg-$end");
	}
    }
    close IN;

    return (\%hg,\%ht);
}

## Adopted from the source code of GLU python module
## Read a string from a binary file where the length is stored in the first (or first+second) byte
sub readIlluBinStr {
    my $fh = shift;
    read($fh,my $n,1);
    $n = ord($n);
    if ( $n == 0 ) { return ""; }  ## return empty string if length is 0
    elsif ( $n > 127 ) {           ## if the string length is over 127 bytes, use the second byte too
        read($fh,my $m,1);         
        $m = ord($m);
        if ( $m > 0 ) {
            $n += (($m-1)*128);
        }
    }
    read($fh,my $buf,$n);

    #die "$n $buf\n";

    return $buf;
}

sub readBin {
    my ($fh,$nbyte,$fmt,$offset) = @_;
    seek($fh,$offset,0) if ( defined($offset) );
    read($fh,my $val,$nbyte);
    $val = unpack($fmt,$val);
    #print STDERR "$fmt\t$nbyte\t$val\n";
    return($val);
}

sub loadIlluIdat {
    my $fn = shift;
    my $sz = (-s $fn);
    my $buf;
    die "Cannot open $fn for reading\n" unless ($sz);

    open(my $fh,$fn) || die "Cannot open $fn for reading\n";
    read($fh,my $sig,4);
    die "Invalid IDAT signature - $sig\n" if ( $sig ne "IDAT" );

    read($fh,my $ver,4); $ver = unpack('L',$ver);
    die "Invalid IDAT version number: $ver\n" unless ( $ver == 3 );

    read($fh,my $unknown0,4); $unknown0 = unpack('L',$unknown0);
    read($fh,my $fieldCount,4); $fieldCount = unpack('L',$fieldCount);
    #print STDERR "fieldCount = $fieldCount\n";

    my %foff = ();
    for(my $i=0; $i < $fieldCount; ++$i) {
	my $fieldCode = &readBin($fh,2,'S');
	my $fieldOffset = &readBin($fh,8,'Q');
	die "Unrecognized IDAT field code $fieldCode\n" unless (defined($idatFieldCodes{$fieldCode}));
	my $field = $idatFieldCodes{$fieldCode};
	#print STDERR "$fieldCode ($field) = $fieldOffset\n";
	$foff{$field} = $fieldOffset;
    }


    die "Cannot find nSNPsRead\n" unless ( defined($foff{"nSNPsRead"}) );
    my $snpCount = &readBin($fh,4,'L',$foff{"nSNPsRead"});

    seek($fh,$foff{"IlluminaID"},0);
    read($fh,$buf,4*$snpCount);
    my @ilmnIDs = unpack('L*',$buf);

    seek($fh,$foff{"SD"},0);
    read($fh,$buf,2*$snpCount);
    my @sds = unpack('S*',$buf);

    seek($fh,$foff{"Mean"},0);
    read($fh,$buf,2*$snpCount);
    my @means = unpack('S*',$buf);

    seek($fh,$foff{"NBeads"},0);
    read($fh,$buf,$snpCount);
    my @nbeads = unpack('c*',$buf);

    my $midBlockCount = &readBin($fh,4,"L",$foff{"MidBlock"});
    read($fh,$buf,4*$midBlockCount);
    my @midblocks = unpack('L*',$buf);

    seek($fh,$foff{"RedGreen"},0);
    read($fh,$buf,4);
    my @redGreens = unpack('CCCC',$buf); 

    seek($fh,$foff{"Manifest"},0);
    my $manifest = &readIlluBinStr($fh);

    seek($fh,$foff{"Barcode"},0);
    my $barcode = &readIlluBinStr($fh);

    seek($fh,$foff{"ChipType"},0);
    my $chiptype = &readIlluBinStr($fh);

    seek($fh,$foff{"Stripe"},0);
    my $stripe = &readIlluBinStr($fh);

    seek($fh,$foff{"SampleID"},0);
    my $sampleID = &readIlluBinStr($fh);

    seek($fh,$foff{"Plate"},0);
    my $plate = &readIlluBinStr($fh);

    seek($fh,$foff{"Well"},0);
    my $well = &readIlluBinStr($fh);

    for(my $i=0; $i < $snpCount; ++$i) {
	print "$ilmnIDs[$i]\t$sds[$i]\t$means[$i]\t$nbeads[$i]\t$midblocks[$i]\n";
    }
    #print join(",",$snpCount,$midBlockCount,@redGreens,$barcode,$chiptype,$stripe);
}

## Module to read a binary BPM file of Illumina Manifest - Adopted by the GLU software package written in python
## This returns a map information file needed to produce a PLINK .bim formatted file
## The number of array elements are equal to the total SNP count
## Each array element contains [snpID, chr, pos, alleleA, alleleB]
sub loadIlluBpm {
    my $fn = shift;
    my $sz = (-s $fn);
    die "Cannot open $fn for reading\n" unless ($sz);

    open(my $fh,$fn) || die "Cannot open $fn for reading\n";
    read($fh,my $sig,3);
    die "Invalid BPM signature - $sig\n" if ( $sig ne "BPM" );

    read($fh,my $ver,5);
    my $manifestName = &readIlluBinStr($fh);
    my $controls = &readIlluBinStr($fh);
    read($fh,my $snpCount,4);
    $snpCount = unpack('L',$snpCount);

    #die "snpCount = $snpCount\n";

    my @snpInfo = ();
    my %hidx = ();
    read($fh,my $snpEntries,4*$snpCount); 
    for(my $i=0; $i < $snpCount; ++$i) { 
	my $snpID = &readIlluBinStr($fh);
	push(@snpInfo,[$snpID,undef,undef,undef,undef]);
	$hidx{$snpID} = $#snpInfo;
    }
    read($fh,my $snpTypes,$snpCount);

    for(my $i=0; $i < $snpCount; ++$i) {
        read($fh, my $rver, 4);
        $rver = unpack("L",$rver);
        my $ilmnid = &readIlluBinStr($fh);
        my $name = &readIlluBinStr($fh);
        read($fh, my $dummy1, 8);
        my $strand = &readIlluBinStr($fh);
        my $alleles = &readIlluBinStr($fh);
        my $chromosome = &readIlluBinStr($fh);
        my $ploidy = &readIlluBinStr($fh);
        my $species = &readIlluBinStr($fh);
        my $mapinfo = &readIlluBinStr($fh);
        my $topGenomicSequence = &readIlluBinStr($fh);
        my $customerStrand = &readIlluBinStr($fh);
        read($fh, my $addressIDs, 8);
	my ($addA,$addB) = unpack('LL',$addressIDs);
	print "$addA\n";
	#print "$addB\n" if ( $addB > 0);
        my $alleleAProbeSequence = &readIlluBinStr($fh);
        my $alleleBProbeSequence = &readIlluBinStr($fh);
        my $genomeVersion = &readIlluBinStr($fh);
        my $source = &readIlluBinStr($fh);
        my $sourceVersion = &readIlluBinStr($fh);
        my $sourceStrand = &readIlluBinStr($fh);
        my $sourceSequence = &readIlluBinStr($fh);
        read($fh, my $endSutff, 20) if ( $rver == 7 );

	my $idx = $hidx{$name};
	die "FATAL ERROR: Cannot find SNP Name $name from the meta-data\n" unless ( defined($idx) );

	my ($alleleA,$alleleB) = ($1,$2) if ( $alleles =~ /^\[(\S)\/(\S)\]/ );
	die "Cannot parse allele information '$alleles' at marker $name $chromosome:$mapinfo ($idx)\n" unless ( defined($alleleB) );

	$snpInfo[$idx]->[1] = $chromosome;
	$snpInfo[$idx]->[2] = $mapinfo;
	$snpInfo[$idx]->[3] = $alleleA;
	$snpInfo[$idx]->[4] = $alleleB;
    }
    return \@snpInfo;
}

sub forkExecWait {
    my $cmd = shift;
    print "forkExecWait(): $cmd\n";
    my $kidpid;
    if ( !defined($kidpid = fork()) ) {
	die "Cannot fork: $!";
    }
    elsif ( $kidpid == 0 ) {
	exec($cmd);
	die "Cannot exec $cmd: $!";
    }
    else {
	waitpid($kidpid,0);
    }
    return ($?>>8);
}

sub zopen {
    my $fn = shift;
    my $reg = shift;
    my $fh = FileHandle->new;
    if ( $fn =~ /\.gz$/ ) {
	die "Cannot open file $fn\n" unless ( -s $fn );
	if ( defined($reg) && ( $reg ) ) {
	    die "Cannot parse $reg\n" unless ( $reg =~ /^\S+:\d+(-\d+)?/ );
	    die "Cannot open file $fn.tbi\n" unless ( -s "$fn.tbi" );
	    open($fh,"$bintabix -h $fn $reg |");
	}
	else {
	    open($fh,"zcat $fn|");
	}
    }
    else {
	die "Cannot parse region $reg in a plain text\n" if ( defined($reg) && ( $reg ) );
	if ( $fn eq "-" ) {
	    $fh = *STDIN;
	    #open($fh,"|") || die "Cannot open $fn\n";
	}
	else {
	    open($fh,$fn) || die "Cannot open $fn\n";
	}
    }
    return $fh;
}

sub wopen {
    my $fn = shift;
    my $fh = FileHandle->new;
    if ( $fn =~ /\.gz$/ ) {
	open($fh,"| $binbgzip -c > $fn");
    }
    else {
	if ( $fn eq "-" ) {
	    $fh = *STDOUT;
	    #open($fh,"|") || die "Cannot open $fn\n";
	}
	else {
	    open($fh,">$fn") || die "Cannot open $fn\n";
	}
    }
    return $fh;
}

sub tofpos {
    my ($chr,$pos) = @_;

    return "100.0" unless ( defined($chr) && defined($pos) );
    
    my $nchr = $chr;
    unless ( $chr =~ /^\d+$/ ) {
        &initRef() unless ( %hszchrs );
	die "Cannot find $chr\n" unless ( defined($hszchrs{$chr}) );
	$nchr = $hszchrs{$chr}->[4];
    }
    return sprintf("%d.%09d",$nchr,$pos);
}

sub fromfpos {
    my $fpos = shift;
    my ($nchr,$pos) = split(/\./,$fpos);
    $pos =~ s/^0+//;
    &initRef() unless ( %hszchrs );
    die "Cannot parse $fpos\n" if ( $#achrs + 1 < $nchr );
    return ($achrs[$nchr-1],$pos);
}

sub iupacCompatible {
    my ($iupac,$nuc) = @_;
    return ( defined($iupacNuc{"$iupac$nuc"}) ? 1 : 0 );
}

sub batchCmd {
    my ($cmd, $batchopts, $batchtype) = @_;
    $cmd =~ s/'/"/g; # Avoid issues with single quotes in command

    my $newcmd = $binruncluster." ";
    if ($batchopts) {
        $newcmd .= "-opts '".$batchopts."' ";
    }
    $newcmd .= "$batchtype '$cmd'";
    return $newcmd;
}

## subroutines to maintain BED
sub sortedBedInsert {
    my ($rh,$chr,$beg,$end,@others) = @_;
    unless ( defined($rh->{$chr}) ) {
	$rh->{$chr} = [ [0,0], [1e9,1e9] ];
    }

    my $rchr = $rh->{$chr};
    my $i = &sortedBedSearch($rchr,$beg,$end);
    splice(@$rchr, $i, 0, [$beg,$end,@others]);
}

## subroutines push to sorted BED, assuming that it is inserted in a sorted order
sub sortedBedPush {
    my ($rh,$chr,$start,$end,@others) = @_;
    unless ( defined($rh->{$chr}) ) {
	$rh->{$chr} = [ [0,0], [1e9,1e9] ];
    }
    my $rchr = $rh->{$chr};
    my $i = $#{$rchr};
    if ( ( $rchr->[$i-1]->[0] > $start ) || 
	 ( ( $rchr->[$i-1]->[0] == $start ) && ( $rchr->[$i-1]->[1] > $end ) ) ) {
	die "sortedBedPush(): Order is not maintained between $chr:".($rchr->[$i-1]->[0])."-".($rchr->[$i-1]->[1])." and $chr:$start-$end\n";
    }
    splice(@$rchr, $i, 0, [$start,$end,@others]);
}

## Binary search on BED file to find the spot to insert
sub sortedBedSearch {
    my ($rchr, $beg, $end) = @_;

    ## perform binary search
    my $l = 0;
    my $r = $#{$rchr}+1;
    my $m = int($r/2);
    while( $l < $r ) {
	if ( $beg < $rchr->[$m]->[0] ) {
	    $r = $m;
	    $m = int(($l + $r) / 2);
	}
	elsif ( $beg > $rchr->[$m]->[0] ) {
	    $l = $m+1;
	    $m = int(($l + $r) / 2);
	}
	else { ## same
	    if ( $end < $rchr->[$m]->[1] ) {
		$r = $m;
		$m = int(($l + $r) / 2);
	    }
	    else {
		$l = $m+1;
		$m = int(($l + $r) / 2);
	    }
	}
    }
    return($l);
}

## merge overlapping BED intervals. All other fields will be deleted
sub sortedBedMerge {
    my ($rh) = @_;
    foreach my $chr (keys %$rh) {
	my @a = ();
	my $rchr = $rh->{$chr};
	my ($beg,$end) = (0,0);
	foreach my $r ( @$rchr ) {
	    if ( $r->[0] <= $end ) { ## overlap. needs to be extended
		$end = $r->[1] if ( $r->[1] > $end ) ## no change
	    }
	    else {  ## does not overlap
		push(@a, [$beg,$end]);
		($beg,$end) = ($r->[0],$r->[1]);
	    }
	}
	push(@a, [$beg,$end]);
	push(@a, [1e9, 1e9]);
	$rh->{$chr} = \@a;
    }
}

## Invert overlapping BED intervals
sub sortedBedInvert {
    my ($rh, $nomerge) = @_;
    unless ( defined($nomerge) && ( $nomerge == 1 ) ) {
	&sortedBedMerge($rh); ## merge first
    }
    foreach my $chr (keys %$rh) {
	my $rchr = $rh->{$chr};	
	my ($cur,$sz) = (0,$hszchrs{$chr}->[3]);
	my @a = ([0,0]);
	foreach my $r ( @$rchr ) {
	    die "foo.. $chr\n" unless ( ( defined($r->[0]) ) && ( defined($cur) ) && ( defined($sz) ) );
	    if ( $cur < $r->[0] ) {
		if ( $r->[0] < $sz ) {
		    push(@a,[$cur,$r->[0]]);
		}
		else {
		    push(@a,[$cur,$sz]);
		}
	    }
	    $cur = $r->[1];
	}
	push(@a, [1e9, 1e9]);
	$rh->{$chr} = \@a;
    }
}

## Sum over possible BED intervals
sub sortedBedSize {
    my $rh = shift;
    my $sum = 0;
    foreach my $chr (keys %$rh) {
	my $rchr = $rh->{$chr};	
	foreach my $r ( @$rchr ) {
	    die "foo..\n" unless ( defined($r->[1]) );
	    if ( ( $r->[1] > 0 ) && ( $r->[0] < 1e9 ) ) {
		$sum += ( $r->[1] - $r->[0] );
	    }
	}
    }
    return ($sum);
}

## print the BED file into output
sub sortedBedPrint {
    my ($rh, $fh) = @_;

    foreach my $chr (@achrs) {
	if ( defined($rh->{$chr}) ) {
	    my $rchr = $rh->{$chr};
	    foreach my $r ( @$rchr ) {
		if ( ( $r->[1] > 0 ) && ( $r->[0] < 1e9 ) ) {
		    print $fh join("\t",$chr,@{$r})."\n";
		}
	    }	    
	}
    }
}

## prevent "Argument list too long" error by using xargs need to write a file to store the arguments
sub xargsCmd {
    my ($file, $cmd) = @_;
    open(OUT,">$file") || die "Cannot open file $file for writing\n";
    print OUT $cmd;
    close OUT;
    return "cat $file | xargs time";
}

sub mosixCmd {
    my ($cmd,$mosixopts) = @_;
    if ( $mosixopts ) {
	return "\t".&batchCmd($cmd,$mosixopts,"mosix")."\n";
	#return "\tmosbatch -E/tmp $mosixopts sh -c '$cmd'\n";
    }
    else {
	return "\t$cmd\n";
    }
}

sub joinps {
    my ($sep,$prefix,$suffix,@ids) = @_;
    if ( $#ids < 0 ) { return ""; }
    else { return "$prefix".(join("$suffix$sep$prefix",@ids))."$suffix"; }
}

sub makeMake {
    my ($outf,$mosixOpt,@cmds) = @_;
    unless ( -s $outf ) {
	mkdir($outf) || die "Cannot create directory $outf\n";
    }
    open(OUT,">$outf.Makefile") || die "Cannot open file\n";
    print OUT ".DELETE_ON_ERROR:\n\n";
    print OUT "all:";
    for(my $i=0; $i < @cmds; ++$i) {
	print OUT " $outf/$i.OK";
    }
    print OUT "\n\n";
    for(my $i=0; $i < @cmds; ++$i) {
	if ( $mosixOpt ) {
	    my $sec = sprintf("%.1lf",rand(30));
	    $cmds[$i] = "sleep $sec;\tmosbatch $mosixOpt sh -c '$cmds[$i]'";
	}
	print OUT "$outf/$i.OK:\n\t$cmds[$i]\n\ttouch $outf/$i.OK\n\n";
    }
    close OUT;
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

## slicenglue - 
## slice -- (required) reference to the subroutine for running each slide
## glue  -- (required) reference to the subroutine for combining the results
## njobs -- Maximum mumber of jobs to run concurrently []
## how   -- how to slice inputs into chunks (genome, num) [genome]
## ref   -- <how=genome> reference FASTA file indexed [/data/local/ref/gotcloud.ref/human.g1k.v37.fa]
## region -- <how=genome> set of regions to slice and glue (e.g. auto, autoX, wgs, 20:0-1000000) [auto]
## unit  -- unit of chunks (in base pairs or chunks) [1e9]
## max   -- <how=num> (required) maximum number of sequence []
# sub slicenglue {
#     ## PART I : Parse the arguments and slice into chunks
#     my %opts = @_;
#     my $njobs = $opts{"$njobs"};
#     my $how = $opts{"$how"};
#     my $unit = $opts{"$unit"};

#     my @chrs = ();
#     my @begs = ();
#     my @ends = ();

#     if ( $how eq "genome" ) {
# 	my $ref = $opts{"ref"};
# 	my $region = $opts{"$region"};

# 	if ( ( $region eq "auto" ) || ( $region eq "autoX" ) || ( region eq "wgs" ) ) {
# 	    foreach my $chr (@achrs) {
# 		my $pass;
# 		if ( $chr =~ /^(chr)?\d+$/ )  {
# 		    $pass = 1;
# 		}
# 		elsif ( $chr =~ /^(chr)?X$/ ) {
# 		    $pass = 1 if ( $region ne "auto" );
# 		}
# 		elsif ( $chr =~ /^(chr)?(Y|M|MT|mt)$/ ) {
# 		    $pass = 1 if ( $region eq "wgs" );
# 		}

# 		if ( $pass ) {
# 		    my $sz = $hszchrs{$chr}->[3];
# 		    for(my $i=0; $i < $sz; $i += $unit) {
# 			push(@chrs,$chr);
# 			push(@begs,$i);
# 			push(@ends,$i + $unit > $sz ? $sz : $i + $unit-1);
# 		    }
# 		}
# 	    }
# 	}
# 	else {
# 	    my ($chr,$beg,$end) = split(/[:\-]/,$opts{"region"});
# 	    unless ( defined($beg) && defined($end) ) {
# 		$beg = 0;
# 		&initRef($ref);
# 		die "Cannot find chromosome $chr\n" unless ( defined($hszchrs{$chr}) );
# 		$end = $hszchrs{$chr}->[3];
# 	    }
# 	    push(@chrs,$chr);
# 	    push(@begs,$beg);
# 	    push($ends,$end);
# 	}
#     }
#     elsif ( $how eq "num" ) {
# 	my $max = $opts{"max"};
# 	die "option max is required\n" unless ( defined($max) );
# 	for(my $i=0; $i <= $max; $i += $unit ) {
# 	    push(@chrs,0);
# 	    push(@begs,$i);
# 	    push(@ends,$i+$unit > $max ? $max : $i + $unit -1);
# 	}
#     }
#     else {
# 	die "Unrecognized value $how for option how";
#     }

#     my @jobs = ();
#     my @outs = ();

#     ## STEP 2 : run each slice separately
#     if ( defined($njobs) ) {
# 	#die "njobs is not currently supported\n";
# 	## if njobs is not set, run everything concurrently
# 	my $nact :shared = 0;

# 	for(my $i=0; $i < @chrs; ++$i) {
# 	    push(@jobs, threads->create( 
# 		     sub { 
# 			 while ( $nact < $njobs ) {
# 			     sleep(10); ## refresh every 10 seconds
# 			 }
# 			 ++$nact;
# 			 return &{$slice}; 
# 		     } ));
# 	}
# 	foreach my $job (@jobs) {
# 	    push(@outs,$job->join());
# 	    --$nact;
# 	}
#     }
#     else {
# 	## if njobs is not set, run everything concurrently
# 	for(my $i=0; $i < @chrs; ++$i) {
# 	    push(@jobs, threads->create( sub { &{$slice}; } ));
# 	}
# 	foreach my $job (@jobs) {
# 	    push(@outs,$job->join());
# 	}
#     }

#     ## STEP 3 : merge slices together
#     return (&glue,\@chrs,\@begs,\@ends,\@outs);
# }


=head1 NAME

 #=============================================
 #  value = getAbsPath ( file, type )
 #=============================================

=head1 DESCRIPTION

    Get the absolute path for the specified file.
    Heirachy for determining absolute path from a relative path:
       1) Based on Type:
           a) FASTQ: FASTQ_PREFIX
       2) Based on BASE_PREFIX (if <TYPE>_PREFIX is not set)
       3) Relative to the current working directory,

=cut

sub getAbsPath {
    my ($file, $type) = @_;

    #   Check if the path is already absolute
    if ( ($file =~ /^\//) ) { return($file); }

    #   Must be a relative path
    my $newPath = '';

    # Check if type was set.
    if ( defined($type) && ($type ne '') ) {
        #   Check if a directory was defined for this type.
        my $val1 = getConf($type . '_PREFIX');
        if( defined($val1) && ($val1 ne '') ) { $newPath = "$val1/$file"; }
    }
    #   Type specific directory is not set, so check if BASE_PREFIX is set.
    if (! $newPath) {
        my $val = getConf('BASE_PREFIX');
        if ($val) { $newPath = "$val/$file"; }
    }
    if (! $newPath) { $newPath = $file; }

    #   Convert to absolute path
    my $fullPath = abs_path($newPath);
    if ( ! defined($fullPath) || ($fullPath eq '') ) {
        if( ($newPath =~ /^\//) ) { die "ERROR: Could not find $newPath\n"; }
        die "ERROR: Could not find $newPath in " . getcwd() . "\n";
    }
    return($fullPath);
}

#==================================================================

=head1 NAME

 #=============================================
 #  value = getIntConf( key, required )
 #=============================================

=head1 DESCRIPTION

    Get the value for a config value. If it is set,
    verify the value is a number.  If not, die.

=cut

sub getIntConf {
    my ($key, $required) = @_;
    my $val = getConf($key, $required);

    if (! $val) { return $val; }
    if (! looks_like_number($val)) {
        die "$key can only be set to a number, not $val\n";
    }
    return $val;
}


our %CONF_HASH = ();                # Configuration values (hash of hashes)
our %BASE_SECTION = ();             # Hash of section to its base
#
#   VERBOSE settings:
#       0       nothing shown
#       >=1     processing activity shown
#       >1      Die just does warn and returns ''  (for testing)
#       >=3     config entries before and after substitutions written to STDERR (not warn)
#       >3      parse of key=value shown
#       
my $VERBOSE = 0;


sub loadConf {
    my ($settingsRef, $configsRef, $v) = @_;
    if (defined($v) && $v) { $VERBOSE = $v; }

    if ($VERBOSE) { warn "Processing configuration files:\n"; }
    my $errs = 0;
    # Process $configs in reverse order.
    for (my $i=$#$configsRef; $i>=0; $i--) {
        if ($VERBOSE) { warn "  Config: $configsRef->[$i]\n"; }
        $errs += ReadConfig($configsRef->[$i]);
    }

    # Process the string settings in reverse order.
    if ($VERBOSE) { warn "  Config: Strings from caller\n"; }
    for (my $i=$#$settingsRef; $i>=0; $i--) {
        if (parseKeyVal($settingsRef->[$i])) {
            warn "Failed: Unable to parse configuration setting:\n  $settingsRef->[$i]\n";
            $errs++;
        }
    }

    if ($VERBOSE > 3) {
        foreach my $sec (sort keys %CONF_HASH) {
            print STDERR "Before substitution:  Section=$sec\n";
            foreach my $k (sort keys %{$CONF_HASH{$sec}}) { print STDERR "  $k=$CONF_HASH{$sec}{$k}\n"; }
        }
    }

    return $errs;
}

sub dumpConf
{
    my ($outputFile) = @_;

    # first check that the file does not already exist.
    if(-e $outputFile)
    {
        warn "$outputFile already exists, so not dumping configuration\n";
        return;
    }
    open(OUT,"> ".($outputFile || '-')) || die "Cannot open $outputFile for writing.  $!\n";

    # first print out the global section.
    my $defaultSection = 'global';
    foreach my $key (keys %{$CONF_HASH{$defaultSection}})
    {
        print OUT "$key = $CONF_HASH{$defaultSection}{$key}\n";
    }
    # Print out the rest of the sections.
    foreach my $section (keys %CONF_HASH)
    {
        next if($section eq $defaultSection);
        foreach my $key (keys %{$CONF_HASH{$section}})
        {
            print OUT "$key = $CONF_HASH{$section}{$key}\n";
        }
    }
    if((defined($outputFile)) && $outputFile eq '')
    {
        close(OUT);
    }

}

#==================================================================

=head1 NAME

 #=============================================
 #  setConf ( key, value )
 #=============================================

=head1 DESCRIPTION

    Sets a value in a global hash.
    Key may be a simple varname in which case the section will be 'global'.
    If the key is of the form name/keyname, then we set the variable
    'keyname' in the section 'name'.

    No substitution is done for variables in value.

=head1 USAGE

    setConf('FASTQ_PREFIX', '');
    setConf('MAP_TYPE', 'BWA');
    setConf('BWA/THREADS', 3);

=cut

sub setConf {
    my ($key, $value) = @_;
    if ($key =~ /^(\w+)\/(.+)/) {
        $CONF_HASH{$1}{$2} = $value;
        return;
    }
    $CONF_HASH{global}{$key} = $value;
}

#==================================================================

=head1 NAME

 #=============================================
 #  value = getConf ( key[, required] )
 #=============================================

=head1 DESCRIPTION

    Gets a value for a key in some section of the global hash.
    If required is not TRUE and the key does not exist, return ''
    otherwise fail.

    Key may be a simple varname in which case the section will be 'global'.
    If the key is of the form name/keyname, then we return the value of the
    variable 'keyname' in the section 'name'.

=head1 USAGE

    $fpfx = getConf('FASTQ_PREFIX');
    $type = getConf('MAP_TYPE', 1);
    $threads = getConf('BWA/THREADS');

=cut

sub getConf {
    my ($key, $required) = @_;

    #print STDERR "getConf() : @_\n";
    
    if (! defined($required)) { $required = 0; }

    my $section = 'global';
    if ($key =~ /^(\w+)\/(.+)/) { ($section, $key) = ($1, $2); }

    # Check this section for the key.
    my $checkSection = $section;
    my $val;
    # if it isn't in this seciton, keep checking base sections
    while(!defined $val && defined $checkSection)
    {
        $val = $CONF_HASH{$checkSection}{$key};
        last if($checkSection eq 'global');
        $checkSection = $BASE_SECTION{$checkSection};
    }

    if(!defined $val)
    {
        if (! $required) { return ''; }
        warn "Failed: Required configuration key '$key' in section '$section' not found in the configuration files\n";
        if ($VERBOSE > 1) { return ''; }        # Sometimes do not die (for testing)
        exit(7);
    }

    #   Resolve sub-variables of the form $(varname)
    for (1 .. 50) {             # Avoid any chance of forever looops
        if ($val !~ /^(.*)\$\(([\w\/]+)\)(.*)$/) { last; }
        my ($pre, $var, $post) = ($1, $2, $3);
        $checkSection = $section;
        my $found;

        # Check if the sub-variable has a '/' in it.
        if($var =~ /(\w+)\/(\w+)/)
        {
            my ($varSection, $varKey) = ($1, $2);
            # check if the sub-variable's section is a parent for this section.
            while((defined $checkSection) && ($checkSection ne 'global') &&
                  ($checkSection ne $varSection))
            {
                $checkSection = $BASE_SECTION{$checkSection};
            }
            if($checkSection ne $varSection)
            {
                # the section is not a parent, so call to get its value.
                $val = $pre . getConf($var, $required).$post;
                next; # go to the next sub-var.
            }
            # The checkSection is set to the sub-var's section - which
            # is a parent to this section, so will use this section's info
            # in any further substitutions (which is why this isn't recursive)
            # Now check for this key rather than the original one with the
            # section in it.
            $var = $varKey;
        }

        # Check the section for the sub-variable.
        if (exists($CONF_HASH{$checkSection}{$var})) {
            $val = $pre . $CONF_HASH{$checkSection}{$var} . $post;
            next;
        }

        # Didn't find it in the section, so check the base if not global.
        while(defined $checkSection && $checkSection ne 'global')
        {
            $checkSection = $BASE_SECTION{$checkSection};
            if(exists($CONF_HASH{$checkSection}{$var}))
            {
                $val = $pre . $CONF_HASH{$checkSection}{$var} . $post;
                $found = 1;
                last;
            }
        }
        if(defined $found)
        {
            next;
        }

#print "NOT_FOUND\n";

        my $s = "'$section'";
        if ($section ne 'global') { $s .= " or in 'global'"; }
        warn "Config variable '$var' is not defined in section $s." .
        "   Line=$CONF_HASH{$section}{$key}\n";
        #$errs++;
        $val = $pre . '_NOT_DEFINED_' . $post;
    }

    return $val;
}

#==================================================================
#  Local functions
#==================================================================

#==================================================================
#  errs = ReadConfig ($file)
#    Uses global config area %CONF_HASH
#
#  Returns:  number of errors detected
#==================================================================
sub ReadConfig {
    my $file = shift;
    my $section = 'global';             # Default section
    my $errs = 0;

    if (! open(IN, $file)) {
        warn "Failed: Unable to open config file '$file': $!\n";
        return 1;
    }
    while (<IN>) {
        next if (/^#/ );                # Ignore comments
        next if (/^\s*$/);              # Ignore blank lines
        s/\s+#.*$//;                    # Remove in-line comments
        #   Sections look like [ name ]
        if (/^\[\s*(\w+)\s*\]\s*(?::\s*(\w+)\s*)?$/ ) {
            $section = $1;
            if(defined $2)
            {
                $BASE_SECTION{$section} = $2;
            }
            else
            {
                $BASE_SECTION{$section} = 'global';
            }
            next;
        }
        #   Rest looks like  key=value
        if(parseKeyVal($_, $section) != 0)
        {
            warn "Failed: Unable to parse config line \n" .
                "  File='$file', line number=" . ($.+1) . "\n" .
                "  Line=$_";
            $errs++;
            next;
        }
    }
    close(IN);
    return $errs;
}

#==================================================================
#   errs = parseKeyVal ($line, $section)
#       Uses global config area %CONF_HASH
#       $section defaults to 'global' 
#
#   Returns:  number of errors detected
#==================================================================
sub parseKeyVal {
    my ($line, $section) = @_;
    if(!defined($section)) {$section = 'global';}

    if ($line !~ /^\s*(\w+)\s*=\s*(.*?)\s*$/ )
    {
        # failed to parse.
        return 1;
    }
    my ($key,$val) = ($1,$2);
    if ( ! defined($val) ) { $val = ''; }  # Undefined is null string
    $CONF_HASH{$section}{$key} = $val;
    if($VERBOSE > 3) { warn "    $section:$key = $val\n";
    }
    return 0;  # Success
}

#==================================================================
#   Perldoc Documentation
#==================================================================
1;                                  # So Perl require is happy
__END__

=head1 AUTHOR

This was written by Mary Kate Wing I<E<lt>mktrost@umich.eduE<gt>>
and Terry Gliedt I<E<lt>tpg@umich.eduE<gt>> in 2013.
This code is made available under terms of the GNU General Public License.

=cut



1;
