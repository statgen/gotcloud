#!/usr/bin/perl -w

####################################################################
# umake.pl
# Main script for UMAKE SNP calling pipeline
# Usage : 
# - STEP 1 : perl umake.pl --conf [config-file]
# - STEP 2 : make -f [out-prefix].Makefile -j [# parallel jobs]
###################################################################

use strict;
use Cwd;
use Getopt::Long;
use File::Path qw(make_path);

my %hConf = ();
my $nSM;

#############################################################################
## loadConf() : load configuration file and build hash table for configuration
############################################################################
sub loadConf {
    my $conf = shift;
    %hConf = ();
    open(IN,$conf) || die "Cannot open $conf file for reading";
    while(<IN>) {
	next if ( /^#/ );  # if the line starts with #, regard them as comment line
	s/#.*$//;          # trim in-line comment lines starting with #
	my ($key,$val);
	if ( /^([^=]+)=(.+)$/ ) {
	    ($key,$val) = ($1,$2);
	}
	else {
	    die "Cannot parse line $_ at line $. in $conf\n";
	}

	$key =~ s/^\s+//;  # remove leading whitespaces
	$key =~ s/\s+$//;  # remove trailing whitespaces
	if ( !defined($val) ) {
	    $val = "";     # if value is undefined, set it as empty string
	}
	else {
	    $val =~ s/^\s+//;
	    $val =~ s/\s+$//;
	}

	# check if predefined key exist and substitute it if needed
	while ( $val =~ /\$\((\S+)\)/ ) {
	    my $subkey = $1;
	    my $subval = &getConf($subkey);
	    if ($subval eq "") {
		die "Cannot parse configuration value $val at line $. of $conf\n";
	    }
	    $val =~ s/\$\($subkey\)/$subval/;
	}
	$hConf{$key} = $val;

	## if BAM_INDEX exists, count # of samples
	if ( $key eq "BAM_INDEX" ) {
	    ($nSM) = split(/\s+/,`wc -l $val`);
	}
	elsif ( $key eq "FILTER_MAX_SAMPLE_DP" ) {
	    die "BAM_INDEX defined before $key\n" unless defined($nSM);
	    $hConf{"FILTER_MAX_TOTAL_DP"} = $nSM * $val;
	}
	elsif ( $key eq "FILTER_MIN_SAMPLE_DP" ) {
	    die "BAM_INDEX defined before $key\n" unless defined($nSM);
	    $hConf{"FILTER_MIN_TOTAL_DP"} = $nSM * $val;
	}
    }
    close IN;
}

#############################################################################
## getConf() : access configuration hash table to contain a value
############################################################################
sub getConf {
    my $key = shift;

    if ( defined($hConf{$key}) ) {
	return $hConf{$key};
    }
    else {
	return "";
	#die "Cannot find key $key in the configuration file\n";
    }
}

#############################################################################
## getMosixCmd() : convert a command to mosix command
############################################################################
sub getMosixCmd {
    my $cmd = shift;
    if ( &getConf("MOS_PREFIX") eq "" ) {
	return $cmd;
    }
    else {
	my $mosNodes = &getConf("MOS_NODES");
	my $newcmd = &getConf("MOS_PREFIX")." -j$mosNodes sh -c '$cmd'";
	return $newcmd;
    }
}

#############################################################################
## parseTarget() : Read UCSC BED format as target information 
##                 allowing a certain offset from the target
##                 merge overlapping extended intervals if possible 
############################################################################
sub parseTarget {
    my ($bed,$offset) = @_;
    my %loci = ();
    # read BED file and construct old loci file
    open(IN,$bed) || die "Cannot open $bed\n";
    while(<IN>) {
	my ($chr,$start,$end) = split;
	if ( $chr =~ /^chr/ ) {
	    $chr = substr($chr,3);
	}
	$loci{$chr} = [] unless defined($loci{$chr});

	$start = ( $start-$offset < 0 ) ? 0 : $start-$offset;
	$end = $end + $offset;
	push(@{$loci{$chr}},[$start+1,$end]);
    }
    close IN;

    # sort by starting position
    foreach my $chr (sort keys %loci) {
	my @s = sort { $a->[0] <=> $b->[0] } @{$loci{$chr}};
	## if regions overlap, merge them. 
	for(my $j=1; $j < @s; ++$j) {
	    if ( $s[$j-1]->[1] < $s[$j]->[0] ) {
		## prev-L < prev-R < next-L < next-R
		## do not merge intervals
	    }
	    else {
		## merge the intervals
		my $mergedMin = $s[$j-1]->[0];
		my $mergedMax = $s[$j-1]->[1];
		$mergedMax = $s[$j]->[1] if ( $mergedMax < $s[$j]->[1] );
		splice(@s,$j-1,2,[$mergedMin,$mergedMax]);
		--$j; 
	    }
	}
	$loci{$chr} = \@s;
    }
    return \%loci;
}

#############################################################################
## STEP 1 : Load configuration file
############################################################################
my $conf = "";
my $snpcallOpt = "";
my $extractOpt = "";
my $beagleOpt = "";
my $thunderOpt = "";
my $out = "";

my $optResult = GetOptions("conf=s",\$conf,
			   "snpcall",\$snpcallOpt,
			   "extract",\$extractOpt,
			   "beagle",\$beagleOpt,
			   "thunder",\$thunderOpt,
			   "out=s",\$out
    );

my $usage = "Usage: umake.pl --conf [conf.file]\nOptional Flags:\n\t--snpcall\tcall SNPs (PILEUP to SPLIT)\n\t--beagle\tGenotype refinement using beagle\n\t--thunder\tGenotype refinement using thunder (after running beagle)";
die "Error in parsing options\n$usage\n" unless ( ($optResult) && ($conf) );

&loadConf($conf);

if ( $out ne "" ) {
    $hConf{"OUT_PREFIX"} = $out;
}

#### POSSIBLE FLOWS ARE
## SNPcall : PILEUP -> GLFMULTIPLES -> VCFPILEUP -> FILTER -> SPLIT : 1,2,3,4,6
## Extract : PILEUP -> GLFEXTRACT -> SPLIT : 1,5,6
## BEAGLE  : BEAGLE -> SUBSET : 7,8
## THUNDER : THUNDER -> 9
my @orders = qw(RUN_INDEX RUN_PILEUP RUN_GLFMULTIPLES RUN_VCFPILEUP RUN_FILTER RUN_EXTRACT RUN_SPLIT RUN_BEAGLE RUN_SUBSET RUN_THUNDER);
my @orderFlags = ();

## if --snpcall --beagle --subset or --thunder
if ( ( $snpcallOpt) || ( $beagleOpt ) || ( $thunderOpt ) || ( $extractOpt ) ) {
    foreach my $o (@orders) {
	push(@orderFlags, 0);
	$hConf{$o} = "FALSE";
    }
    if ( $snpcallOpt ) {
	foreach my $i (1,2,3,4,6) { # PILEUP to SPLIT
	    $orderFlags[$i] = 1;
	    $hConf{$orders[$i]} = "TRUE";
	}
    }
    if ( $extractOpt ) {
	foreach my $i (1,5,6) { # PILEUP, EXTRACT, SPLIT
	    $orderFlags[$i] = 1;
	    $hConf{$orders[$i]} = "TRUE";
	}
    }
    if ( $beagleOpt ) {
	foreach my $i (7,8) {
	    $orderFlags[$i] = 1;
	    $hConf{$orders[$i]} = "TRUE";
	}
    }
    if ( $thunderOpt ) {
	foreach my $i (9) {
	    $orderFlags[$i] = 1;
	    $hConf{$orders[$i]} = "TRUE";
	}
    }
}
else {
    foreach my $o (@orders) {
	push(@orderFlags, ( &getConf($o) eq "TRUE") ? 1 : 0 );
    }
}

## check if the current orders are compatible with any of the valid orders
my @validOrders = ([0,1,2,3,4,6],[0,1,5,6],[7,8],[9]);
my $validFlag = 0;
foreach my $v (@validOrders) {
    my @vjs = ();
    my $i;
    for($i=0; $i < @orderFlags; ++$i) {
	if ( $orderFlags[$i] == 1 ) {
	    my $found = 0;
	    for(my $j=0; $j < @{$v}; ++$j) {
		if ( $v->[$j] == $i ) {
		    push(@vjs,$j);
		    $found = 1;
		}
	    }
	    last if ( $found == 0 );
	}
    }
    #print "$i\n";
    if ( $i == $#orderFlags + 1 ) { 
	for(my $j=1; $j < @vjs; ++$j) {
	    if ( $vjs[$j] != $vjs[$j-1]+1 ) {
		next;
	    }
	}
	$validFlag = 1;
    }
}

print STDERR "Processing the following steps...\n";
for(my $i=0; $i < @orderFlags; ++$i) {
    if ( $orderFlags[$i] == 1 ) {
	print STDERR ($i+1);
	print STDERR ": $orders[$i]\n";
    }
}

if ( $validFlag == 0 ) {
    die "ERROR IN CONF FILE : Options are not compatible. Use --snpcall, --extract, --beagle, --thunder or compatible subsets\n";
}


#############################################################################
## STEP 2 : Parse BAM INDEX FILE
############################################################################
my $bamIndex = &getConf("BAM_INDEX");
my $pedIndex = &getConf("PED_INDEX");
my %hSM2bams = ();  # hash mapping sample IDs to bams
my %hSM2pops = ();  # hash mapping sample IDs to bams
my %hSM2sexs = ();  # hash mapping sample IDs to bams
my @allbams = ();   # list of all bamss
my @allbamSMs = (); # list of all samples corresponding to each BAM
my @allSMs = ();    # list of all unique sample IDs
my %hPops = ();

open(IN,$bamIndex) || die "Cannot open $bamIndex file\n";
while(<IN>) {
    my ($smID,$pop,@bams) = split;
    my @mpops = split(/,/,$pop);

    if ( defined($hSM2pops{$smID}) || defined($hSM2bams{$smID}) ) {
	die "Duplicated sample ID $smID\n";
    }

    $hSM2pops{$smID} = \@mpops;
    $hSM2bams{$smID} = \@bams;
    foreach my $mpop (@mpops) {
	$hPops{$mpop} = 1;
    }
    push(@allbams,@bams);
    foreach my $bam (@bams) {
	die "FATAL ERROR: All BAM filepath must be absolute path when running in the cluster" if ( !( $bam =~ /^\// ) && ( &getConf("MOS_PREFIX") ne "" ) );
	push(@allbamSMs,$smID);

	if ( &getConf("ASSERT_BAM_EXIST") eq "TRUE" ) {
#	$bam =~ s/\s+//g;
	    unless ( -s $bam ) {
		die "Cannot locate '$bam'\n";
	    }
	}
    }
    push(@allSMs,$smID);
}
close IN;

if ( $pedIndex ne "" ) {
    open(IN,$pedIndex) || die "Cannot open $pedIndex file\n";
    while(<IN>) {
	my ($famID,$indID,$fatID,$motID,$sex) = split;
	die "Cannot recognize $indID in $pedIndex\n" unless defined($hSM2bams{$indID});
	$hSM2sexs{$indID} = $sex;
    }
    close IN;
    foreach my $id (@allSMs) {
	die "Cannot find $id in $pedIndex\n" unless defined($hSM2sexs{$id});
    }
}
else {
    foreach my $id (@allSMs) {
	$hSM2sexs{$id} = 2;
    }
}

my @pops = sort keys %hPops;

## Create BAM INDICES
my $outDir = &getConf("OUT_DIR");
unless ( $outDir =~ /^\// ) {
    $outDir = getcwd()."/".$outDir;
}

#############################################################################
## STEP 3 : Create MAKEFILE
############################################################################
my $makef = &getConf("OUT_DIR")."/".&getConf("OUT_PREFIX").".Makefile";
my @chrs = split(/\s+/,&getConf("CHRS"));
my @nobaqSubstrings = split(/\s+/,&getConf("NOBAQ_SUBSTRINGS"));

`mkdir --p $outDir`;

open(MAK,">$makef") || die "Cannot open $makef for writing\n";
print MAK ".DELETE_ON_ERROR:\n\n";
print MAK "all:";
foreach my $chr (@chrs) {
    print MAK " all$chr";
}
print MAK "\n\n";

#############################################################################
## STEP 4 : Read FASTA INDEX file to determin chromosome size
############################################################################
my %hChrSizes = ();
open(IN,&getConf("REF").".fai") || die "Cannot open ".&getConf("REF").".fai file for reading";
while(<IN>) {
    my ($chr,$len) = split;
    $hChrSizes{$chr} = $len;
}
close IN;

#############################################################################
## STEP 5 : CONFIGURE PARAMETERS
############################################################################
my $unitChunk = &getConf("UNIT_CHUNK");
my $bamGlfDir = "$outDir/".&getConf("BAM_GLF_DIR");
my $smGlfDir = "$outDir/".&getConf("SM_GLF_DIR");
my $vcfDir = "$outDir/".&getConf("VCF_DIR");
my $pvcfDir = "$outDir/".&getConf("PVCF_DIR");
my $splitDir = "$outDir/".&getConf("SPLIT_DIR");
my $targetDir = "$outDir/".&getConf("TARGET_DIR");
my $beagleDir = "$outDir/".&getConf("BEAGLE_DIR");
my $thunderDir = "$outDir/".&getConf("THUNDER_DIR");
my $remotePrefix = &getConf("REMOTE_PREFIX");
my $ref = &getConf("REF");

my $bamIndexRemote = ($bamIndex =~ /^\//) ? "$remotePrefix$bamIndex" : ($remotePrefix.&getcwd()."/".$bamIndex);

#############################################################################
## STEP 6 : PARSE TARGET INFORMATION
############################################################################
my $multiTargetMap = &getConf("MULTIPLE_TARGET_MAP");
my $uniformTargetBed = &getConf("UNIFORM_TARGET_BED");

my %hBedIndices = ();
my @uniqBeds = ();
my @uniqBedFns = ();
my @targetIntervals = ();
my %hBeds =();

if ( ( $uniformTargetBed ne "" ) && ( $multiTargetMap ne "" ) ) {
    die "Cannot define both UNIFORM_TARGET_BED and MULTIPLE_TARGET_MAP. Use one or the other\n";
}
elsif ( $uniformTargetBed ne "" ) {
    ## There is one target for every sample
    $hBeds{$uniformTargetBed} = 0;
    push(@uniqBeds,$uniformTargetBed);
    my $bedFn = +(split(/\//,$uniformTargetBed))[-1];
    push(@uniqBedFns,$bedFn);
    for(my $i=0; $i < @allSMs; ++$i) {
	$hBedIndices{$allSMs[$i]} = 0;
    }
}
elsif ( $multiTargetMap ne "" ) {
    ## There is multiple targets for every sample
    my %hSM2BedIndex = ();
    open(IN,$multiTargetMap) || die "Cannot open file $multiTargetMap\n";
    while(<IN>) {
	my ($id,$bed) = split;
	unless (defined($hBeds{$bed}) ) {
	    $hBeds{$bed} = $#uniqBeds+1;
	    push(@uniqBeds,$bed);
	    my $bedFn = +(split(/\//,$bed))[-1];
	    push(@uniqBedFns,$bedFn);
	}
	$hSM2BedIndex{$id} = $hBeds{$bed};
    }
    close IN;

    for(my $i=0; $i < @allSMs; ++$i) {
	die "Cannot find target information for sample $allSMs[$i]\n" unless (defined($hSM2BedIndex{$allSMs[$i]}));
	$hBedIndices{$allSMs[$i]} = $hSM2BedIndex{$allSMs[$i]};
    }
}

foreach my $bed (@uniqBeds) {
    my $r = parseTarget($bed,&getConf("OFFSET_OFF_TARGET"));
    push(@targetIntervals,$r);
}

#############################################################################
## ITERATE EACH CHROMOSOME
############################################################################
foreach my $chr (@chrs) {
    print STDERR "Processing chr$chr...\n";
    die "Cannot find chromosome name $chr in the reference file\n" unless (defined($hChrSizes{$chr}));
    my @unitStarts = ();
    my @unitEnds = ();
    
    #############################################################################
    ## STEP 8 : PARITION THE CHROMSOME INTO REGIONS
    #############################################################################
    for(my $j=0; $j < $hChrSizes{$chr}; $j += $unitChunk) {
	my $start = sprintf("%d",$j+1);
	my $end = ($j+$unitChunk > $hChrSizes{$chr}) ? $hChrSizes{$chr} : sprintf("%d",$j+$unitChunk);
	## if targeted sequencing, 
	## check if the region overlaps with any of the known targets
	my $inTarget = ($#uniqBeds < 0) ? 1 : 0;
	if ( $inTarget == 0 ) {
	    for(my $k=0; ($k < @uniqBeds) && ( $inTarget == 0) ; ++$k) {
		foreach my $p (@{$targetIntervals[$k]->{$chr}}) {
		    ## check if any of target overlaps
		    unless ( ( $p->[1] < $start ) || ( $p->[0] > $end ) ) {
			$inTarget = 1;
			last;
		    }
		}
	    }
	}
	if ( $inTarget == 1 ) {
	    push(@unitStarts,$start);
	    push(@unitEnds,$end);
	}
    }

    #############################################################################
    ## STEP 9 : WRITE .loci file IF NECESSARY
    #############################################################################
    if ( ( &getConf("WRITE_TARGET_LOCI") eq "TRUE" ) && ( &getConf("RUN_PILEUP") eq "TRUE" ) ) {
	die "No target file is given but WRITE_TARGET_LOCI is TRUE\n" if ( $#uniqBeds < 0 );

	## Generate target loci information
	for(my $i=0; $i < @uniqBeds; ++$i) {
	    print STDERR "Writing target loci for $uniqBeds[$i]..\n";
	    my $outDir = "$targetDir/$uniqBedFns[$i]/chr$chr";
	    make_path($outDir);
	    for(my $j=0; $j < @unitStarts; ++$j) {
		print STDERR "Writing loci for $chr:$unitStarts[$j]-$unitEnds[$j]..\n";
		open(LOCI,">$outDir/$chr.$unitStarts[$j].$unitEnds[$j].loci") || die "Cannot create $outDir/$chr.loci\n";
		foreach my $p (@{$targetIntervals[$i]->{$chr}}) {
		    my $start = ( $p->[0] < $unitStarts[$j] ) ? $unitStarts[$j] : $p->[0];
		    my $end = ( $p->[1] < $unitEnds[$j] ) ? $p->[1] : $unitEnds[$j];
		    #die "@{$p} $start $end\n";
		    for(my $k=$start; $k <= $end; ++$k) {
			print LOCI "$chr\t$k\n";
		    }
		}
		close LOCI;
	    }
	}
    }

    #############################################################################
    ## STEP 10 : MAIN PART TO WRITE MAKEFILE
    #############################################################################
    print MAK "all$chr:";
    print MAK " thunder$chr" if ( &getConf("RUN_THUNDER") eq "TRUE" );
    print MAK " subset$chr" if ( &getConf("RUN_SUBSET") eq "TRUE" );
    print MAK " beagle$chr" if ( &getConf("RUN_BEAGLE") eq "TRUE" );
    print MAK " split$chr" if ( &getConf("RUN_SPLIT") eq "TRUE" );
    print MAK " filt$chr" if ( &getConf("RUN_EXTRACT") eq "TRUE" );
    print MAK " filt$chr" if ( &getConf("RUN_FILTER") eq "TRUE" );
    print MAK " pvcf$chr" if ( &getConf("RUN_VCFPILEUP") eq "TRUE" );
    print MAK " vcf$chr" if ( &getConf("RUN_GLFMULTIPLES") eq "TRUE" );
    print MAK " glf$chr" if ( &getConf("RUN_PILEUP") eq "TRUE" );
    print MAK " bai" if ( &getConf("RUN_INDEX") eq "TRUE" );
    print MAK "\n\n";

    #############################################################################
    ## STEP 10-9 : RUN MaCH GENOTYPE REFINEMENT
    #############################################################################
    if ( &getConf("RUN_THUNDER") eq "TRUE" ) {
	print MAK "thunder$chr:";
	foreach my $pop (@pops) {
	    my $thunderPrefix = "$thunderDir/chr$chr/$pop/thunder/chr$chr.filtered.PASS.beagled.$pop.thunder";
	print MAK " $thunderPrefix.vcf.gz.tbi";
	}
	print MAK "\n\n";
	
	foreach my $pop (@pops) {
	    my $splitPrefix = "$thunderDir/chr$chr/$pop/split/chr$chr.filtered.PASS.beagled.$pop.split";
	    open(IN,"$splitPrefix.vcflist") || die "Cannot open $splitPrefix.vcflist\n";
	    my @splitVcfs = ();
	    for(my $i=1;<IN>;++$i) {
		chomp;
		if ( /^\// ) {
		    push(@splitVcfs,"$remotePrefix$_");
		}
		else {
		    die "$splitPrefix.vcflist must contain absolute filepath\n";
		}
	    }
	    close IN;
	    my $nsplits = $#splitVcfs+1;
	    
	    my $thunderPrefix = "$thunderDir/chr$chr/$pop/thunder/chr$chr.filtered.PASS.beagled.$pop.thunder";
	    my @thunderOuts = ();
	    my $thunderOutPrefix = $thunderPrefix;
	    for(my $i=0; $i < $nsplits; ++$i) {
		my $j = $i+1;
		my $thunderOut = "$thunderOutPrefix.$j";
		push(@thunderOuts,$thunderOut);
	    }
	    
	    print MAK "$thunderPrefix.vcf.gz.tbi: ".join(".vcf.gz.OK ",@thunderOuts).".vcf.gz.OK\n";
	    print MAK "\t".&getConf("LIGATEVCF")." ".join(".vcf.gz ",@thunderOuts).".vcf.gz 2> $thunderPrefix.vcf.gz.err | ".&getConf("BGZIP")." -c > $thunderPrefix.vcf.gz\n";
	    print MAK "\t".&getConf("TABIX")." -f -pvcf $thunderPrefix.vcf.gz\n\n";
	    
	    for(my $i=0; $i < $nsplits; ++$i) {
		my $j = $i+1;
		my $thunderOut = "$thunderOutPrefix.$j";
		print MAK "$thunderOut.vcf.gz.OK:\n";
		print MAK "\tmkdir --p $thunderDir/chr$chr/$pop/thunder\n";
		my $cmd = &getConf("THUNDER")." --shotgun $splitVcfs[$i] -o $remotePrefix$thunderOut > $remotePrefix$thunderOut.out 2> $remotePrefix$thunderOut.err";
		print MAK "\t".&getMosixCmd($cmd)."\n";
		$cmd = "touch $thunderOut.vcf.gz.OK";
		print MAK "\t$cmd\n";
		print MAK "\n";
	    }
	}
    }

    #############################################################################
    ## STEP 10-8 : SUBSET INTO POPULATION GROUPS FOR THUNDER REFINEMENT
    #############################################################################
    if ( &getConf("RUN_SUBSET") eq "TRUE" ) {
	my $expandFlag = ( &getConf("RUN_BEAGLE") eq "TRUE" ) ? 1 : 0;
    
	print MAK "subset$chr:";
	foreach my $pop (@pops) {
	    print MAK " $thunderDir/chr$chr/$pop/split/chr$chr.filtered.PASS.beagled.$pop.split.vcflist";
	}
	print MAK "\n\n";
	
	my $nLdSNPs = &getConf("LD_NSNPS");
	my $nLdOverlap = &getConf("LD_OVERLAP");
	my $mvcf = "$remotePrefix$vcfDir/chr$chr/chr$chr.filtered.vcf.gz";
	
	if ( $expandFlag == 1 ) {
	    print MAK "$beagleDir/chr$chr/subset.OK: beagle$chr\n";
	}
	else {
	    print MAK "$beagleDir/chr$chr/subset.OK:\n";
	}
	my $beaglePrefix = "$beagleDir/chr$chr/chr$chr.filtered.PASS.beagled";
	if ( $#pops > 0 ) {
	    my $cmd = &getConf("VCFCOOKER")." --in-vcf $remotePrefix$beaglePrefix.vcf.gz --out $remotePrefix$beaglePrefix --subset --in-subset $bamIndexRemote --bgzf 2> $remotePrefix$beaglePrefix.subset.err";
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    print MAK "\n";
	    foreach my $pop (@pops) {
		print MAK "\t".&getConf("TABIX")." -f -pvcf $remotePrefix$beaglePrefix.$pop.vcf.gz\n";
	    }
	}
	else {
	    print MAK "\tln -f -s $remotePrefix$beaglePrefix.vcf.gz $remotePrefix$beaglePrefix.$pops[0].vcf.gz\n";
	    print MAK "\tln -f -s $remotePrefix$beaglePrefix.vcf.gz.tbi $remotePrefix$beaglePrefix.$pops[0].vcf.gz.tbi\n";
	}
	print MAK "\ttouch $beagleDir/chr$chr/subset.OK\n\n";
	
	foreach my $pop (@pops) {
	    my $splitPrefix = "$thunderDir/chr$chr/$pop/split/chr$chr.filtered.PASS.beagled.$pop.split";
	    print MAK "$splitPrefix.vcflist: $beagleDir/chr$chr/subset.OK\n";
	    print MAK "\tmkdir --p $thunderDir/chr$chr/$pop/split/\n";
	    my $cmd = &getConf("VCFSPLIT")." --in $remotePrefix$beaglePrefix.$pop.vcf.gz --out $remotePrefix$splitPrefix --nunit $nLdSNPs --noverlap $nLdOverlap 2> $remotePrefix$splitPrefix.err";
	    print MAK "\t".&getMosixCmd($cmd)."\n\n";
	}
    }

    #############################################################################
    ## STEP 10-7 : RUN BEAGLE GENOTYPE REFINEMENT
    #############################################################################
    if ( &getConf("RUN_BEAGLE") eq "TRUE" ) {
	my $beaglePrefix = "$beagleDir/chr$chr/chr$chr.filtered.PASS.beagled";
	print MAK "beagle$chr: $beaglePrefix.vcf.gz.tbi\n\n";

	my $splitPrefix = "$splitDir/chr$chr/chr$chr.filtered.PASS.split";
	open(IN,"$splitPrefix.vcflist") || die "Cannot open $splitPrefix.vcflist\n";
	my @splitVcfs = ();
	while(<IN>) {
	    chomp;
	    push(@splitVcfs,$_);
	}
	close IN;
	my $nsplits = $#splitVcfs+1;

	my @beagleOuts = ();
	my $beagleOutPrefix = "$beagleDir/chr$chr/split/bgl";
	for(my $i=0; $i < $nsplits; ++$i) {
	    my $j = $i+1;
	    my $beagleOut = "$beagleOutPrefix.$j.chr$chr.PASS.$j";
	    push(@beagleOuts,$beagleOut);
	}

	print MAK "$beaglePrefix.vcf.gz.tbi: ".join(".vcf.gz.tbi ",@beagleOuts).".vcf.gz.tbi\n";
	print MAK "\t".&getConf("LIGATEVCF")." ".join(".vcf.gz ",@beagleOuts).".vcf.gz 2> $beaglePrefix.vcf.gz.err | ".&getConf("BGZIP")." -c > $beaglePrefix.vcf.gz\n";
	print MAK "\t".&getConf("TABIX")." -f -pvcf $beaglePrefix.vcf.gz\n";
	print MAK "\n";

	my $beagleLikeDir = "$beagleDir/chr$chr/like";
	for(my $i=0; $i < $nsplits; ++$i) {
	    my $j = $i+1;
	    my $beagleOut = "$beagleOutPrefix.$j.chr$chr.PASS.$j";
	    print MAK "$beagleOut.vcf.gz.tbi:\n";
	    print MAK "\tmkdir --p $beagleLikeDir\n";
	    print MAK "\tmkdir --p $beagleDir/chr$chr/split\n";
	    print MAK "\tsleep ".($i*20 % 1000)."\n";
	    my $cmd = &getConf("VCF2BEAGLE")." --in $splitVcfs[$i] --out $remotePrefix$beagleLikeDir/chr$chr.PASS.$j.gz";
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    $cmd = &getConf("BEAGLE")." like=$remotePrefix$beagleLikeDir/chr$chr.PASS.".($i+1).".gz out=$remotePrefix$beagleOutPrefix.$j >$remotePrefix$beagleOutPrefix.$j.out 2>$remotePrefix$beagleOutPrefix.$j.err";
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    $cmd = &getConf("BEAGLE2VCF"). " --filter --beagle $remotePrefix$beagleOut.gz --invcf $splitVcfs[$i] --outvcf $remotePrefix$beagleOut.vcf";
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    $cmd = "/usr/cluster/bin/bgzip -f $remotePrefix$beagleOut.vcf";
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    $cmd = "/usr/cluster/bin/tabix -f -pvcf $remotePrefix$beagleOut.vcf.gz";
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    print MAK "\n";
	}
    }

    #############################################################################
    ## STEP 10-6 : SPLIT FILTERED VCF INTO CHUNKS FOR GENOTYPING
    #############################################################################
    if ( &getConf("RUN_SPLIT") eq "TRUE" ) {
	# determine whether to expand to lower level target or not
	my $expandFlag = ( &getConf("RUN_FILTER") eq "TRUE" ) ? 1 : 0;
	$expandFlag = 1 if ( &getConf("RUN_EXTRACT") eq "TRUE" );
	
	print MAK "split$chr:";
	my $splitPrefix = "$splitDir/chr$chr/chr$chr.filtered.PASS.split";
	print MAK " $splitPrefix.vcflist";
	print MAK "\n\n";
	
	my $nLdSNPs = &getConf("LD_NSNPS");
	my $nLdOverlap = &getConf("LD_OVERLAP");
	my $mvcf = "$remotePrefix$vcfDir/chr$chr/chr$chr.filtered.vcf.gz";
	
	my $subsetPrefix = "$splitDir/chr$chr/chr$chr.filtered";
	if ( $expandFlag == 1 ) {
	    print MAK "$splitDir/chr$chr/subset.OK: filt$chr\n";
	}
	else {
	    print MAK "$splitDir/chr$chr/subset.OK:\n";
	}
	print MAK "\tmkdir --p $splitDir/chr$chr\n";
	print MAK "\t(zcat $mvcf | head -100 | grep ^#; zcat $mvcf | grep -w PASS;) | ".&getConf("BGZIP")." -c > $subsetPrefix.PASS.vcf.gz\n";
	print MAK "\ttouch $splitDir/chr$chr/subset.OK\n\n";
	
	print MAK "$splitPrefix.vcflist: $splitDir/chr$chr/subset.OK\n";
	print MAK "\tmkdir --p $splitDir/chr$chr\n";
	my $cmd = &getConf("VCFSPLIT")." --in $remotePrefix$subsetPrefix.PASS.vcf.gz --out $remotePrefix$splitPrefix --nunit $nLdSNPs --noverlap $nLdOverlap 2> $remotePrefix$splitPrefix.err";
	print MAK "\t".&getMosixCmd($cmd)."\n\n";
    }

    #############################################################################
    ## STEP 10-6b : SPLIT FILTERED VCF INTO CHUNKS FOR GENOTYPING
    #############################################################################
    if ( &getConf("RUN_EXTRACT") eq "TRUE" ) {
	my $expandFlag = ( &getConf("RUN_PILEUP") eq "TRUE" ) ? 1 : 0;
	my $vcfParent = "$remotePrefix$vcfDir/chr$chr";
	my $vcf = "$vcfParent/chr$chr.filtered.vcf";
	my @vcfs = ();
	my @svcfs = ();
	for(my $j=0; $j < @unitStarts; ++$j) {
	    $vcfParent = "$remotePrefix$vcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
	    push(@vcfs,"$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].vcf");
	    push(@svcfs,"$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].sites.vcf");
	}

	my $invcf = &getConf("VCF_EXTRACT");
	unless ( ( $invcf =~ /.gz$/ ) && ( -s $invcf ) && ( -s "$invcf.tbi" ) ) {
	    die "Input VCF file $invcf must be bgzipped and tabixed\n";
	}

	print MAK "filt$chr: $vcf.OK".(($expandFlag == 1) ? " glf$chr" : "")."\n\n";
	print MAK "$vcf.OK: ";
	print MAK join(".OK ",@vcfs);
	print MAK ".OK\n";
	print MAK "\t(cat $vcfs[0] | head -100 | grep ^#; cat @vcfs | grep -v ^#;) | ".&getConf("BGZIP")." -c > $vcf.gz\n";
	print MAK "\ttouch $vcf.OK\n\n";

	for(my $j=0; $j < @unitStarts; ++$j) {
	    $vcfParent = "$remotePrefix$vcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
	    print MAK "$svcfs[$j].OK:\n";
	    print MAK "\tmkdir --p $vcfParent\n";
	    print MAK "\t".&getConf("TABIX")." $invcf $chr:$unitStarts[$j]-$unitEnds[$j] | cut -f 1-8 > $svcfs[$j]\n";
	    print MAK "\ttouch $svcfs[$j].OK\n\n";

	    my @glfs = ();
	    my $smGlfParent = "$remotePrefix$smGlfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
	    for(my $i=0; $i < @allSMs; ++$i) {
		my $smGlfFn = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
		my $smGlf = "$smGlfParent/$smGlfFn";
		push(@glfs,$smGlf);
	    }

	    make_path($smGlfParent);
	    open(AL,">$smGlfParent/".&getConf("GLF_INDEX")) || die "Cannot open file $smGlfParent/".&getConf("GLF_INDEX")." for writing\n";
	    print STDERR "Creating glf INDEX at $chr:$unitStarts[$j]-$unitEnds[$j]..\n";
	    for(my $i=0; $i < @allSMs; ++$i) {
		my $smGlfFn = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
		my $smGlf = "$smGlfParent/$smGlfFn";
		print AL "$allSMs[$i]\t$allSMs[$i]\t0\t0\t$hSM2sexs{$allSMs[$i]}\t$smGlf\n";
	    }
	    close AL;

	    my $glfAlias = "$smGlfParent/".&getConf("GLF_INDEX");
	    my $sleepSecs = ($j % 10)*20;
	    my $cmd = &getConf("GLFEXTRACT")." --invcf $svcfs[$j] --ped $glfAlias -b $vcfs[$j] > $vcfs[$j].log 2> $vcfs[$j].err";
	    print MAK "$vcfs[$j].OK: $svcfs[$j].OK ";
	    if ( $expandFlag == 1 ) {
		print MAK join(".OK ",@glfs);
		print MAK ".OK";
	    }
	    print MAK "\n";
#	    print MAK "\tmkdir --p $vcfParent\n";
	    print MAK "\tsleep $sleepSecs\n";
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    print MAK "\ttouch $vcfs[$j].OK\n\n";
	}
    }

    if ( &getConf("MERGE_BEFORE_FILTER") eq "TRUE" ) {
	#############################################################################
	## STEP 10-4B : VCF PILEUP after MERGING
	#############################################################################
	if ( &getConf("RUN_VCFPILEUP") eq "TRUE" ) {
	    # determine whether to expand to lower level target or not
	    my $expandFlag = ( &getConf("RUN_GLFMULTIPLES") eq "TRUE" ) ? 1 : 0;

	    ## Generate gpileup statistics (.pvcf) for every BAMs + merged VCF
	    my @gvcfs = ();
	    my @vcfs = ();
	    my @pvcfs = ();
	    my @cmds = ();
	    
	    my $vcfParent = "$remotePrefix$vcfDir/chr$chr";
	    my $svcf = "$vcfParent/chr$chr.merged.sites.vcf";
	    my $gvcf = "$vcfParent/chr$chr.merged.stats.vcf";
	    my $vcf = "$vcfParent/chr$chr.merged.vcf";

	    for(my $i=0; $i < @allbams; ++$i) {
		my $bam = $allbams[$i];
		my $bamSM = $allbamSMs[$i];
		my @F = split(/\//,$bam);
		my $bamFn = pop(@F);
		my $pvcfParent = "$pvcfDir/chr$chr";
		my $pvcf = "$remotePrefix$pvcfParent/$bamFn.$chr.vcf.gz";
		push(@pvcfs,$pvcf);
		my $cmd = &getConf("VCFPILEUP")." -i $svcf -r $ref -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
		push(@cmds,"$pvcf.OK: $vcf.OK\n\tmkdir --p $pvcfParent\n\t".&getMosixCmd($cmd)."\n\ttouch $pvcf.OK\n");
	    }

	    print MAK "pvcf$chr: ".join(".OK ",@pvcfs).".OK";
	    if ( $expandFlag == 1 ) {
		print MAK " vcf$chr\n\n";
	    }
	    else {
		print MAK "\n\n";
	    }
	    print MAK join("\n",@cmds);
	}

	#############################################################################
	## STEP 10-5B : FILTERING AFTER MERGING
	#############################################################################
	if ( &getConf("RUN_FILTER") eq "TRUE" ) {
	    my $vcfParent = "$remotePrefix$vcfDir/chr$chr";
	    my $svcf = "$vcfParent/chr$chr.merged.sites.vcf";
	    my $gvcf = "$vcfParent/chr$chr.merged.stats.vcf";
	    my $vcf = "$vcfParent/chr$chr.merged.vcf";

	    my @pvcfs = ();
	    for(my $i=0; $i < @allbams; ++$i) {
		my $bam = $allbams[$i];
		my @F = split(/\//,$bam);
		my $bamFn = pop(@F);
		my $pvcfParent = "$pvcfDir/chr$chr";
		my $pvcf = "$remotePrefix$pvcfParent/$bamFn.$chr.vcf.gz";
		push(@pvcfs,$pvcf);
	    }

	    my $expandFlag = ( &getConf("RUN_VCFPILEUP") eq "TRUE" ) ? 1 : 0;
	    my @cmds = ();
	    my $cmd = &getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/chr$chr/ --suffix .$chr.vcf.gz --outvcf $gvcf --index $bamIndexRemote 2> $gvcf.err";
	    
	    my $mvcfPrefix = "$remotePrefix$vcfDir/chr$chr/chr$chr";
	    print MAK "filt$chr: $mvcfPrefix.filtered.vcf.gz.OK\n\n";
	    if ( $expandFlag == 1 ) {
		print MAK "$mvcfPrefix.filtered.vcf.gz.OK: $gvcf.OK pvcf$chr\n";
	    }
	    else {
		print MAK "$mvcfPrefix.filtered.vcf.gz.OK: $gvcf.OK\n";
	    }
	    print MAK "\t".&getConf("VCFCOOKER")." ".&getConf("FILTER_ARGS")." --indelVCF ".&getConf("INDEL_PREFIX").".chr$chr.vcf --out $mvcfPrefix.filtered.sites.vcf --in-vcf $gvcf\n";
	    print MAK "\t".&getConf("VCFPASTE")." $mvcfPrefix.filtered.sites.vcf $mvcfPrefix.merged.vcf | ".&getConf("BGZIP")." -c > $mvcfPrefix.filtered.vcf.gz\n";
	    print MAK "\t".&getConf("TABIX")." -f -pvcf $mvcfPrefix.filtered.vcf.gz\n";
	    print MAK "\t".&getConf("VCFSUMMARY")." --vcf $mvcfPrefix.filtered.sites.vcf --dbsnp ".&getConf("DBSNP_PREFIX").".chr$chr.map --FNRbfile ".&getConf("HM3_PREFIX").".chr$chr > $mvcfPrefix.filtered.sites.vcf.summary\n";
	    print MAK "\ttouch $mvcfPrefix.filtered.vcf.gz.OK\n\n";
	    print MAK join("\n",@cmds);
	    print MAK "\n";
	}
    }
    else {
	#############################################################################
	## STEP 10-4A : VCF PILEUP before MERGING
	#############################################################################
	if ( &getConf("RUN_VCFPILEUP") eq "TRUE" ) {
	    my $expandFlag = ( &getConf("RUN_GLFMULTIPLES") eq "TRUE" ) ? 1 : 0;

	    ## Generate gpileup statistics (.pvcf) for every BAMs + VCF
	    my @gvcfs = ();
	    my @vcfs = ();
	    my @pvcfs = ();
	    my @cmds = ();
	    
	    for(my $j=0; $j < @unitStarts; ++$j) {
		#print STDERR "Yay..\n";
		my $vcfParent = "$remotePrefix$vcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
		my $svcf = "$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].sites.vcf";
		my $gvcf = "$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].stats.vcf";
		my $vcf = "$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].vcf";

		push(@cmds,"$svcf.OK: ".( ($expandFlag == 1) ? "$vcf.OK" : "")."\n\tcut -f 1-8 $vcf > $svcf\n\ttouch $svcf.OK\n");

		for(my $i=0; $i < @allbams; ++$i) {
		    my $bam = $allbams[$i];
		    my $bamSM = $allbamSMs[$i];
		    my @F = split(/\//,$bam);
		    my $bamFn = pop(@F);
		    my $pvcfParent = "$pvcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
		    my $pvcf = "$remotePrefix$pvcfParent/$bamFn.$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz";
		    push(@pvcfs,$pvcf);
		    my $cmd = &getConf("VCFPILEUP")." -i $svcf -r $ref -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
		    push(@cmds,"$pvcf.OK: $svcf.OK\n\tmkdir --p $pvcfParent\n\t".&getMosixCmd($cmd)."\n\ttouch $pvcf.OK\n");
		}
	    }
	    print MAK "pvcf$chr: ".join(".OK ",@pvcfs).".OK";
	    if ( $expandFlag == 1 ) {
		print MAK " vcf$chr\n\n";
	    }
	    else {
		print MAK "\n\n";
	    }
	    print MAK join("\n",@cmds);
	}

	#############################################################################
	## STEP 10-5A : FILTERING before MERGING
	#############################################################################
	if ( &getConf("RUN_FILTER") eq "TRUE" ) {
	    my $expandFlag = ( &getConf("RUN_VCFPILEUP") eq "TRUE" ) ? 1 : 0;
	    my $gmFlag = ( &getConf("RUN_GLFMULTIPLES") eq "TRUE" ) ? 1 : 0;

	    ## Generate gpileup statistics (.pvcf) for every BAMs + VCF
	    my @gvcfs = ();
	    my @vcfs = ();
	    my @cmds = ();
	    
	    for(my $j=0; $j < @unitStarts; ++$j) {
		my $vcfParent = "$remotePrefix$vcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
		my $svcf = "$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].sites.vcf";
		my $gvcf = "$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].stats.vcf";
		my $vcf = "$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].vcf";

		if ( $expandFlag > 0 ) {
		    my @pvcfs = ();

		    for(my $i=0; $i < @allbams; ++$i) {
			my $bam = $allbams[$i];
			my $bamSM = $allbamSMs[$i];
			my @F = split(/\//,$bam);
			my $bamFn = pop(@F);
			my $pvcfParent = "$pvcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
			my $pvcf = "$remotePrefix$pvcfParent/$bamFn.$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz";
			push(@pvcfs,$pvcf);
		    }
		    
		    my $cmd = &getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]/ --suffix .$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz --outvcf $gvcf --index $bamIndexRemote 2> $gvcf.err";
		    push(@cmds,"$gvcf.OK: ".join(".OK ",@pvcfs).".OK".(($gmFlag == 1) ? " $vcf.OK" : "")."\n\t".&getMosixCmd($cmd)."\n\ttouch $gvcf.OK\n\n");
		}
		else {
		    my $cmd = &getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]/ --suffix .$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz --outvcf $gvcf --index $bamIndexRemote 2> $gvcf.err";
		    push(@cmds,"$gvcf.OK:".(($gmFlag == 1) ? " $vcf.OK" : "")."\n\t".&getMosixCmd($cmd)."\n\ttouch $gvcf.OK\n\n");
		}
		push(@gvcfs,$gvcf);
		push(@vcfs,$vcf);
	    }
	    
	    my $mvcfPrefix = "$remotePrefix$vcfDir/chr$chr/chr$chr";
	    print MAK "filt$chr: $mvcfPrefix.filtered.vcf.gz.OK\n\n";
	    print MAK "$mvcfPrefix.filtered.vcf.gz.OK: ".join(".OK ",@gvcfs).".OK ".join(".OK ",@vcfs).".OK".(($gmFlag == 1) ? " $mvcfPrefix.merged.vcf.OK" : "")."\n";
	    if ( $#uniqBeds < 0 ) {
		print MAK "\t".&getConf("VCFMERGE")." $unitChunk @gvcfs > $mvcfPrefix.merged.stats.vcf\n";
	    }
	    else {
		print MAK "\t(cat $gvcfs[0] | head -100 | grep ^#; cat @gvcfs | grep -v ^#;) > $mvcfPrefix.merged.stats.vcf\n";
	    }
	    print MAK "\t".&getConf("VCFCOOKER")." ".&getConf("FILTER_ARGS")." --indelVCF ".&getConf("INDEL_PREFIX").".chr$chr.vcf --out $mvcfPrefix.filtered.sites.vcf --in-vcf $mvcfPrefix.merged.stats.vcf\n";
	    print MAK "\t".&getConf("VCFPASTE")." $mvcfPrefix.filtered.sites.vcf $mvcfPrefix.merged.vcf | ".&getConf("BGZIP")." -c > $mvcfPrefix.filtered.vcf.gz\n";
	    print MAK "\t".&getConf("TABIX")." -f -pvcf $mvcfPrefix.filtered.vcf.gz\n";
	    print MAK "\t".&getConf("VCFSUMMARY")." --vcf $mvcfPrefix.filtered.sites.vcf --dbsnp ".&getConf("DBSNP_PREFIX").".chr$chr.map --FNRbfile ".&getConf("HM3_PREFIX").".chr$chr > $mvcfPrefix.filtered.sites.vcf.summary\n";
	    print MAK "\ttouch $mvcfPrefix.filtered.vcf.gz.OK\n\n";
	    print MAK join("\n",@cmds);
	    print MAK "\n";
	}
    }

    #############################################################################
    ## STEP 10-3 : GLFMULTIPLES
    #############################################################################
    if ( &getConf("RUN_GLFMULTIPLES") eq "TRUE" ) {
	my $expandFlag = ( &getConf("RUN_PILEUP") eq "TRUE" ) ? 1 : 0;
	my @cmds = ();
	my @vcfs = ();

	for(my $j=0; $j < @unitStarts; ++$j) {
	    my $vcfParent = "$remotePrefix$vcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
	    my $vcf = "$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].vcf";
	    my @glfs = ();
	    my $smGlfParent = "$remotePrefix$smGlfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";

	    make_path($smGlfParent);
	    open(AL,">$smGlfParent/".&getConf("GLF_INDEX")) || die "Cannot open file $smGlfParent/".&getConf("GLF_INDEX")." for writing\n";
	    print STDERR "Creating glf INDEX at $chr:$unitStarts[$j]-$unitEnds[$j]..\n";
	    for(my $i=0; $i < @allSMs; ++$i) {
		my $smGlfFn = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
		my $smGlf = "$smGlfParent/$smGlfFn";
		print AL "$allSMs[$i]\t$allSMs[$i]\t0\t0\t$hSM2sexs{$allSMs[$i]}\t$smGlf\n";
	    }
	    close AL;

	    for(my $i=0; $i < @allSMs; ++$i) {	    
		my $smGlfFn = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
		my $smGlf = "$smGlfParent/$smGlfFn";
		push(@glfs,$smGlf);
	    }
	    my $glfAlias = "$smGlfParent/".&getConf("GLF_INDEX");
	    push(@vcfs,$vcf);
	    my $sleepSecs = ($j % 10)*20;
	    my $cmd = &getConf("GLFMULTIPLES")." --ped $glfAlias -b $vcf > $vcf.log 2> $vcf.err";
	    if ( $expandFlag == 1 ) {
		push(@cmds,"$vcf.OK: ".join(".OK ",@glfs).".OK\n\tmkdir --p $vcfParent\n\tsleep $sleepSecs\n\t".&getMosixCmd($cmd)."\n\ttouch $vcf.OK\n");
	    }
	    else {
		push(@cmds,"$vcf.OK:\n\tmkdir --p $vcfParent\n\tsleep $sleepSecs\n\t".&getMosixCmd($cmd)."\n\ttouch $vcf.OK\n");
	    }
	}

	my $out = "$vcfDir/chr$chr/chr$chr.merged";
	print MAK "vcf$chr: $remotePrefix$out.vcf.OK\n\n";
	print MAK "$remotePrefix$out.vcf.OK: ";
	print MAK join(".OK ",@vcfs);
	print MAK ".OK\n";
	if ( $#uniqBeds < 0 ) {
	    print MAK "\t".&getConf("VCFMERGE")." $unitChunk @vcfs > $out.vcf\n";
	}
	else {  ## targeted regions - rely on the loci info
	    print MAK "\t(cat $vcfs[0] | head -100 | grep ^#; cat @vcfs | grep -v ^#;) > $out.vcf\n";
	}
	print MAK "\tcut -f 1-8 $out.vcf > $out.sites.vcf\n";
	print MAK "\ttouch $out.vcf.OK\n\n";
	print MAK join("\n",@cmds);
	print MAK "\n";
    }

    #############################################################################
    ## STEP 10-2 : SAMTOOLS PILEUP TO GENERATE GLF
    #############################################################################
    if ( &getConf("RUN_PILEUP") eq "TRUE" ) {
	## glf[$chr]: all-list-of-sample-glfs
	my @outs = ();
	my @cmds = ();

	for(my $i=0; $i < @allSMs; ++$i) {
	    my @bams = @{$hSM2bams{$allSMs[$i]}};
	    for(my $j=0; $j < @unitStarts; ++$j) {
		my $smGlfParent = "$remotePrefix$smGlfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
		my $smGlfFn = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
		my $smGlf = "$smGlfParent/$smGlfFn";
		    
		my @bamGlfs = ();
		foreach my $bam (@bams) {
		    my @F = split(/\//,$bam);
		    my $bamFn = pop(@F);
		    #my ($runID) = split(/\./,$bamFn);
		    my $bamGlf = "$remotePrefix$bamGlfDir/$allSMs[$i]/chr$chr/$bamFn.$unitStarts[$j].$unitEnds[$j].glf";
		    #my $bamGlf = "$remotePrefix$bamGlfDir/$runID/chr$chr/$bamFn.$unitStarts[$j].$unitEnds[$j].glf";
		    push(@bamGlfs,$bamGlf);
		}
		push(@outs,"$smGlf.OK");
		my $cmd = "$smGlf.OK: ".join(".OK ",@bamGlfs).".OK\n\tmkdir --p $smGlfParent\n\t";
		#my $cmd = "$smGlf.OK:\n\tmkdir --p $smGlfParent\n\t";
		if ( $#bamGlfs > 0 ) {
		    my $qualities = "0";
		    my $minDepths = "1";
		    my $maxDepths = "1000";
		    for(my $k=1; $k < @bamGlfs; ++$k) {
			$qualities .= ",0";
			$minDepths .= ",1";
			$maxDepths .= ",1000";
		    }

		    #unlink($smGlf);
		    #unlink("$smGlf.OK");

		    $cmd .= &getMosixCmd(&getConf("GLFMERGE")." --qualities $qualities --minDepths $minDepths --maxDepths $maxDepths --outfile $smGlf @bamGlfs");
		}
		else {
		    $cmd .= "ln -f -s $bamGlfs[0] $smGlf";
		}
		$cmd .= "\n\ttouch $smGlf.OK\n";
		push(@cmds,$cmd);
	    }
	}

	print MAK "glf$chr: ";
	print MAK join(" ",@outs);
	print MAK "\n\n";
	#print MAK join("\n",@cmds);
	#print MAK "\n";

	for(my $i=0; $i < @allbams; ++$i) {
	    my $bam = $allbams[$i];
	    my $bamSM = $allbamSMs[$i];
	    my @F = split(/\//,$bam);
	    my $bamFn = pop(@F);
	    for(my $j=0; $j < @unitStarts; ++$j) {
		my $bamGlf = "$remotePrefix$bamGlfDir/$bamSM/chr$chr/$bamFn.$unitStarts[$j].$unitEnds[$j].glf";
		my $cmd;
		my $baqFlag = 1;
		foreach my $s (@nobaqSubstrings) {
		    if ( $bam =~ m/($s)/ ) {
			$baqFlag = 0;
		    }
		}
		my $loci = "";
		my $region = "$chr:$unitStarts[$j]-$unitEnds[$j]";
		if ( $#uniqBeds >= 0 ) {
		    my $idx = $hBedIndices{$bamSM};
		    $loci = "-l $targetDir/$uniqBedFns[$idx]/chr$chr/$chr.$unitStarts[$j].$unitEnds[$j].loci";
		    if ( &getConf("SAMTOOLS_VIEW_TARGET_ONLY") eq "TRUE" ) {
			$region = "";
			foreach my $p (@{$targetIntervals[$idx]->{$chr}}) {
			    my $rmin = ($p->[0] > $unitStarts[$j]) ? $p->[0] : $unitStarts[$j];  # take bigger one
			    my $rmax = ($p->[1] > $unitEnds[$j]) ? $unitEnds[$j] : $p->[1];  # take smaller one
			    $region .= " $chr:$rmin-$rmax" if ( $rmin <= $rmax );
			}
			## if no target exists then set region as single base
			$region = "$chr:0-0" if ( $region eq "" );
		    }
		}

		if ( $baqFlag == 0 ) {
		    $cmd = &getConf("SAMTOOLS_FOR_OTHERS")." view ".&getConf("SAMTOOLS_VIEW_FILTER")." -uh $bam $region | ".&getConf("SAMTOOLS_FOR_PILEUP")." pileup -f $ref $loci -g - > $bamGlf";
		}
		else {
		    $cmd = &getConf("SAMTOOLS_FOR_OTHERS")." view ".&getConf("SAMTOOLS_VIEW_FILTER")." -uh $bam $region | ".&getConf("SAMTOOLS_FOR_OTHERS")." calmd -Abr - $ref 2> /dev/null | ".&getConf("SAMTOOLS_FOR_PILEUP")." pileup -f $ref $loci -g - > $bamGlf";
		}
		if ( &getConf("RUN_INDEX") eq "TRUE" ) {
		    push(@cmds,"$bamGlf.OK: bai\n\tmkdir --p $bamGlfDir/$bamSM/chr$chr\n\t".&getMosixCmd($cmd)."\n\ttouch $bamGlf.OK\n");
		}
		else {
		    push(@cmds,"$bamGlf.OK:\n\tmkdir --p $bamGlfDir/$bamSM/chr$chr\n\t".&getMosixCmd($cmd)."\n\ttouch $bamGlf.OK\n");
		}
	    }
	}

	print MAK join("\n",@cmds);
	print MAK "\n";
    }
}

#############################################################################
## STEP 10-1 : INDEX BAMS IF NECESSARY
#############################################################################
if ( &getConf("RUN_INDEX") eq "TRUE" ) {
    my @bamsToIndex = ();
    if ( &getConf("RUN_INDEX_FORCE") eq "TRUE" ) {
	@bamsToIndex = @allbams;
    }
    else {
	foreach my $bam (@allbams) {
	    unless ( -s "$bam.bai" ) {
		push(@bamsToIndex,$bam);
	    }
	}
    }
    print MAK "bai:";
    foreach my $bam (@bamsToIndex) {
	print MAK " $bam.bai.OK";
    }
    print MAK "\n\n";
    foreach my $bam (@bamsToIndex) {
	my $cmd = &getConf("SAMTOOLS_FOR_OTHERS")." index $bam";
	print MAK "$bam.bai.OK:\n\t".&getMosixCmd($cmd)."\n\ttouch $bam.bai.OK\n";
    }
}

close MAK;

print STDERR "--------------------------------------------------------------------\n";
print STDERR "Finished creating makefile $makef\n\n";
print STDERR "Try 'make -f $makef -n | less' for a sanity check before running\n";
print STDERR "Run 'make -f $makef -j [#parallele jobs]'\n";
print STDERR "--------------------------------------------------------------------\n";
