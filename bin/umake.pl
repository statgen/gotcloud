#!/usr/bin/perl -w

####################################################################
# umake.pl
# Main script for UMAKE SNP calling pipeline
# Usage : 
# - STEP 1 : perl umake.pl --conf [config-file]
# - STEP 2 : make -f [out-prefix].Makefile -j [# parallel jobs]
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################
###################################################################

use strict;
use Cwd;
use Getopt::Long;
use File::Path qw(make_path);
use File::Basename;
use Cwd 'abs_path';
use Scalar::Util qw(looks_like_number);

my %hConf = ();
my @keys = ();

# Set the umake base directory.
$_ = abs_path($0);
my($scriptName, $scriptPath) = fileparse($_);
my $scriptDir = abs_path($scriptPath);
if ($scriptDir !~ /(.*)\/bin/) { die "Unable to set basepath. No 'bin' found in '$scriptDir'\n"; }
my $umakeRoot = $1;
$hConf{"UMAKE_ROOT"} = $umakeRoot;

#############################################################################
## STEP 1 : Load configuration file
############################################################################
my $help = "";
my $testdir = "";
my $outdir = "";
my $conf = "";
my $numjobs = 0;
my $snpcallOpt = "";
my $extractOpt = "";
my $beagleOpt = "";
my $thunderOpt = "";
my $outprefix = "";
my $override = "";
my $localdefaults = "";
my $callregion = "";
my $verbose = "";

my $batchtype = '';
my $batchopts = '';
my $runcluster = "$umakeRoot/scripts/runcluster.pl";

my $optResult = GetOptions("help",\$help,
                           "test=s",\$testdir,
                           "outdir|out_dir=s",\$outdir,
                           "conf=s",\$conf,
                           "numjobs=i",\$numjobs,
			   "snpcall",\$snpcallOpt,
			   "extract",\$extractOpt,
			   "beagle",\$beagleOpt,
			   "thunder",\$thunderOpt,
			   "outprefix=s",\$outprefix,
			   "override=s",\$override,
			   "region=s",\$callregion,
                           "batchtype|batch_type=s",\$batchtype,
                           "batchopts|batch_opts=s",\$batchopts,
			   "localdefaults=s",\$localdefaults,
                           "verbose", \$verbose
    );

my $usage = "Usage: umake.pl --conf [conf.file]\nOptional Flags:\n\t--snpcall\tcall SNPs (PILEUP to SPLIT)\n\t--beagle\tGenotype refinement using beagle\n\t--thunder\tGenotype refinement using thunder (after running beagle)";
die "Error in parsing options\n$usage\n" unless ( ($optResult) && (($conf) || ($help) || ($testdir)) );

# check if help.
if ($help) {
  die "$usage\n";
}

my $here = getcwd();                # Where I am now

#   Special case for convenient testing
if($testdir ne "") {
    my $outdir=abs_path($testdir);
    system("mkdir -p $outdir") &&
        die "Unable to create directory '$outdir'\n";
    my $testoutdir = $outdir."/umaketest";
    print "Removing any previous results from: $testoutdir\n";
    system("rm -rf $testoutdir") &&
        die "Unable to clear the test output directory '$testoutdir'\n";
    print "Running GOTCLOUD TEST, test log in: $testoutdir.log\n";
    $testdir = $umakeRoot . '/test/umake';
    my $cmd = "$0 -conf $testdir/umake_test.conf --snpcall " .
        "-outdir $testoutdir --numjobs 2 1> $testoutdir.log 2>&1";
    system($cmd) &&
        die "Failed to generate test data. Not a good thing.\nCMD=$cmd\n";
    $cmd = "$umakeRoot/scripts/diff_results_umake.sh $outdir $umakeRoot/test/umake/expected";
    system($cmd) &&
        die "Comparison failed, test case FAILED.\nCMD=$cmd\n";
    print "Successfully ran the test case, congratulations!\n";
    exit;
}

#-------------
# Handle cluster setup.
if ($batchtype eq 'flux') { $batchtype = 'pbs'; }
$runcluster = abs_path($runcluster);    # Make sure this is fully qualified

&loadOverride($override);
&loadConf($conf);
if($localdefaults ne "") {
 &loadConf($localdefaults);
 }
&loadConf($scriptPath."/umakeDefaults.conf");

if ( $outprefix ne "" ) {
    $hConf{"OUT_PREFIX"} = $outprefix;
}
if ( $outdir ne "" ) {
    $hConf{"OUT_DIR"} = $outdir;
}

# Pull batch info from config if not on command line.
if ( $batchopts eq "" ) {
  $batchopts = $hConf{"BATCH_OPTS"};
}
if ( $batchtype eq "" ) {
  $batchtype = $hConf{"BATCH_TYPE"};
}

#### POSSIBLE FLOWS ARE
## SNPcall : PILEUP -> GLFMULTIPLES -> VCFPILEUP -> FILTER -> SVM -> SPLIT : 1,2,3,4,5,7
## Extract : PILEUP -> GLFEXTRACT -> SPLIT : 1,6,7
## BEAGLE  : BEAGLE -> SUBSET : 8,9
## THUNDER : THUNDER -> 10 
my @orders = qw(RUN_INDEX RUN_PILEUP RUN_GLFMULTIPLES RUN_VCFPILEUP RUN_FILTER RUN_SVM RUN_EXTRACT RUN_SPLIT RUN_BEAGLE RUN_SUBSET RUN_THUNDER);
my @orderFlags = ();

## if --snpcall --beagle --subset or --thunder
if ( ( $snpcallOpt) || ( $beagleOpt ) || ( $thunderOpt ) || ( $extractOpt ) ) {
    foreach my $o (@orders) {
	push(@orderFlags, 0);
	$hConf{$o} = "FALSE";
    }
    if ( $snpcallOpt ) {
	foreach my $i (1,2,3,4,5,7) { # PILEUP to SPLIT
	    $orderFlags[$i] = 1;
	    $hConf{$orders[$i]} = "TRUE";
	}
    }
    if ( $extractOpt ) {
	foreach my $i (1,6,7) { # PILEUP, EXTRACT, SPLIT
	    $orderFlags[$i] = 1;
	    $hConf{$orders[$i]} = "TRUE";
	}
    }
    if ( $beagleOpt ) {
	foreach my $i (8,9) {
	    $orderFlags[$i] = 1;
	    $hConf{$orders[$i]} = "TRUE";
	}
    }
    if ( $thunderOpt ) {
	foreach my $i (10) {
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
my @validOrders = ([0,1,2,3,4,5,7],[0,1,6,7],[8,9],[10]);
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
my $numSteps = 0;
for(my $i=0; $i < @orderFlags; ++$i) {
    if ( $orderFlags[$i] == 1 ) {
	print STDERR ($i+1);
	print STDERR ": $orders[$i]\n";
	++$numSteps;
    }
}

if ( $validFlag == 0 ) {
# foreach (@ARGV) { print STDERR "$_\n" };
#print STDERR qx/ps -o args $$/;
    die "ERROR IN CONF FILE : Options are not compatible. Use --snpcall, --extract, --beagle, --thunder or compatible subsets\n";
}

if ( $numSteps == 0 ) {
    die "ERROR IN CONF FILE : No option is given. Manually configure STEPS_TO_RUN section in the configuration file, or use --snpcall, --extract, --beagle, --thunder or compatible subsets\n";
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
my $numSamples = 0;

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
    foreach my $bam (@bams) {
        if(!($bam =~ /^\// ))
        {
            # check if it starts with a configuration value.
            while($bam =~ /\$\(([^\s)]+)\)/ )
            {
                my $key = $1;
                my $val = &getConf($key);
                $bam =~ s/\$\($key\)/$val/;
            }
            # Check if there is just a relative path to the bams.
            if ( !( $bam =~ /^\// ) )
            {
              # It is relative, so make it absolute.
              my $bamPath = dirname(abs_path($bamIndex));
              $bam = abs_path($bamPath .'/'. $bam);
            }
        }
	push(@allbamSMs,$smID);

	if ( &getConf("ASSERT_BAM_EXIST") eq "TRUE" ) {
#	$bam =~ s/\s+//g;
	    unless ( -s $bam ) {
		die "Cannot locate '$bam'\n";
	    }
	}
    }
    push(@allSMs,$smID);
    push(@allbams,@bams);
}
close IN;

$numSamples = @allSMs;

if ( $pedIndex ne "" ) {
    open(IN,$pedIndex) || die "Cannot open $pedIndex file\n";
    while(<IN>) {
	next if ( /^#/ );
	my ($famID,$indID,$fatID,$motID,$sex) = split;
	#die "Cannot recognize $indID in $pedIndex\n" unless defined($hSM2bams{$indID});
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
print MAK "OUTPUT_DIR=$outDir\n";
print MAK "UMAKE_ROOT=$umakeRoot\n\n";
print MAK ".DELETE_ON_ERROR:\n\n";

# Write the values from the configuration.
#foreach my $key (@keys)
#{
#  print MAK "$key = $hConf{$key}\n";
#}
#
#print MAK "\n";

print MAK "all:";
foreach my $chr (@chrs) {
    print MAK " all$chr";
}
print MAK "\n\n";

#############################################################################
## STEP 4 : Read FASTA INDEX file to determin chromosome size
############################################################################
my %hChrSizes = ();
my $reference = &getConf("REF");
open(IN,&getConf("REF").".fai") || die "Cannot open ".&getConf("REF").".fai file for reading";
while(<IN>) {
    my ($chr,$len) = split;
    $hChrSizes{$chr} = $len;
}
close IN;

my ($callstart,$callend);
if ( $callregion ) {
    if ( $callregion =~ /^([^:]+):(\d+)(\-\d+)?$/ ) {
	@chrs = ($1);
	$callstart = $2;
	$callend = $3 ? substr($3,1) : $hChrSizes{$1};
	print STDERR "Call region is $1:$callstart-$callend\n";
    }
    else {
	die "Cannot recognize option --region $callregion\nExpected format: N:N-N\n";
    }
}


#############################################################################
## STEP 5 : CONFIGURE PARAMETERS
############################################################################
my $unitChunk = &getConf("UNIT_CHUNK");
my $bamGlfDir = "\$(OUTPUT_DIR)/".&getConf("BAM_GLF_DIR");
my $smGlfDir = "\$(OUTPUT_DIR)/".&getConf("SM_GLF_DIR");
my $smGlfDirReal = "$outDir/".&getConf("SM_GLF_DIR");
my $vcfDir = "\$(OUTPUT_DIR)/".&getConf("VCF_DIR");
my $pvcfDir = "\$(OUTPUT_DIR)/".&getConf("PVCF_DIR");
my $splitDir = "\$(OUTPUT_DIR)/".&getConf("SPLIT_DIR");
my $splitDirReal = "$outDir/".&getConf("SPLIT_DIR");
my $targetDir = "\$(OUTPUT_DIR)/".&getConf("TARGET_DIR");
my $targetDirReal = "$outDir/".&getConf("TARGET_DIR");
my $beagleDir = "\$(OUTPUT_DIR)/".&getConf("BEAGLE_DIR");
my $thunderDir = "\$(OUTPUT_DIR)/".&getConf("THUNDER_DIR");
my $thunderDirReal = "$outDir/".&getConf("THUNDER_DIR");
my $remotePrefix = &getConf("REMOTE_PREFIX");
my $ref = &getConf("REF");

my $bamIndexRemote = ($bamIndex =~ /^\//) ? "$remotePrefix$bamIndex" : ($remotePrefix.&getcwd()."/".$bamIndex);

my $sleepMultiplier = &getConf("SLEEP_MULT");
if($sleepMultiplier eq "")
{
  $sleepMultiplier = 0;
}


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

	## if --region was specified, check overlap and skip if necessary
	next if ( defined($callstart) && ( ( $start > $callend ) || ( $end < $callstart ) ) );

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
	    my $outDir = "$targetDirReal/$uniqBedFns[$i]/chr$chr";
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
    print MAK " svm$chr" if ( &getConf("RUN_SVM") eq "TRUE" );
    print MAK " filt$chr" if ( &getConf("RUN_FILTER") eq "TRUE" );
    print MAK " pvcf$chr" if ( &getConf("RUN_VCFPILEUP") eq "TRUE" );
    print MAK " vcf$chr" if ( &getConf("RUN_GLFMULTIPLES") eq "TRUE" );
    print MAK " glf$chr" if ( &getConf("RUN_PILEUP") eq "TRUE" );
    print MAK " bai" if ( &getConf("RUN_INDEX") eq "TRUE" );
    print MAK "\n\n";

    # Use a filter prefix for hard filtering if running SVM
    my $filterPrefix = "";
    if ( &getConf("RUN_SVM") eq "TRUE") {
      $filterPrefix = "hard";
    }

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
	    my $splitPrefix = "$thunderDirReal/chr$chr/$pop/split/chr$chr.filtered.PASS.beagled.$pop.split";
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
            my $cmd = "\t".&getConf("LIGATEVCF")." ".join(".vcf.gz ",@thunderOuts).".vcf.gz 2> $thunderPrefix.vcf.gz.err | ".&getConf("BGZIP")." -c > $thunderPrefix.vcf.gz\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "$cmd";
	    $cmd = "\t".&getConf("TABIX")." -f -pvcf $thunderPrefix.vcf.gz\n\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "$cmd";

	    for(my $i=0; $i < $nsplits; ++$i) {
		my $j = $i+1;
		my $thunderOut = "$thunderOutPrefix.$j";
		print MAK "$thunderOut.vcf.gz.OK:\n";
		print MAK "\tmkdir --p $thunderDir/chr$chr/$pop/thunder\n";
		my $cmd = &getConf("THUNDER")." --shotgun $splitVcfs[$i] -o $remotePrefix$thunderOut > $remotePrefix$thunderOut.out 2> $remotePrefix$thunderOut.err";
                $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
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
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    print MAK "\n";
	    foreach my $pop (@pops) {
		$cmd = "\t".&getConf("TABIX")." -f -pvcf $remotePrefix$beaglePrefix.$pop.vcf.gz\n";
                $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
                print MAK "$cmd";
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
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "\t".&getMosixCmd($cmd)."\n\n";
	}
    }

    #############################################################################
    ## STEP 10-7 : RUN BEAGLE GENOTYPE REFINEMENT
    #############################################################################
    if ( &getConf("RUN_BEAGLE") eq "TRUE" ) {
	my $beaglePrefix = "$beagleDir/chr$chr/chr$chr.filtered.PASS.beagled";
	print MAK "beagle$chr: $beaglePrefix.vcf.gz.tbi\n\n";

	my $splitPrefix = "$splitDirReal/chr$chr/chr$chr.filtered.PASS.split";
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
        my $cmd = "\t".&getConf("LIGATEVCF")." ".join(".vcf.gz ",@beagleOuts).".vcf.gz 2> $beaglePrefix.vcf.gz.err | ".&getConf("BGZIP")." -c > $beaglePrefix.vcf.gz\n";
        $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	print MAK "$cmd";
	$cmd = "\t".&getConf("TABIX")." -f -pvcf $beaglePrefix.vcf.gz\n";
        $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	print MAK "$cmd";
	print MAK "\n";

	my $beagleLikeDir = "$beagleDir/chr$chr/like";
	for(my $i=0; $i < $nsplits; ++$i) {
	    my $j = $i+1;
	    my $beagleOut = "$beagleOutPrefix.$j.chr$chr.PASS.$j";
	    print MAK "$beagleOut.vcf.gz.tbi:\n";
	    print MAK "\tmkdir --p $beagleLikeDir\n";
	    print MAK "\tmkdir --p $beagleDir/chr$chr/split\n";
            my $sleepSecs = $i*$sleepMultiplier % 1000;
            if($sleepSecs != 0)
            {
              print MAK "\tsleep ".$sleepSecs."\n";
            }
	    my $cmd = &getConf("VCF2BEAGLE")." --in $splitVcfs[$i] --out $remotePrefix$beagleLikeDir/chr$chr.PASS.$j.gz";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    $cmd = &getConf("BEAGLE")." like=$remotePrefix$beagleLikeDir/chr$chr.PASS.".($i+1).".gz out=$remotePrefix$beagleOutPrefix.$j >$remotePrefix$beagleOutPrefix.$j.out 2>$remotePrefix$beagleOutPrefix.$j.err";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    $cmd = &getConf("BEAGLE2VCF"). " --filter --beagle $remotePrefix$beagleOut.gz --invcf $splitVcfs[$i] --outvcf $remotePrefix$beagleOut.vcf";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    $cmd = &getConf("BGZIP"). " -f $remotePrefix$beagleOut.vcf";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    $cmd = &getConf("TABIX"). " -f -pvcf $remotePrefix$beagleOut.vcf.gz";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
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
        my $cmd = "\t(zcat $mvcf | head -100 | grep ^#; zcat $mvcf | grep -w PASS;) | ".&getConf("BGZIP")." -c > $subsetPrefix.PASS.vcf.gz\n";
        $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	print MAK $cmd;
	print MAK "\ttouch $splitDir/chr$chr/subset.OK\n\n";
	
	print MAK "$splitPrefix.vcflist: $splitDir/chr$chr/subset.OK\n";
	print MAK "\tmkdir --p $splitDir/chr$chr\n";
        $cmd = &getConf("VCFSPLIT")." --in $remotePrefix$subsetPrefix.PASS.vcf.gz --out $remotePrefix$splitPrefix --nunit $nLdSNPs --noverlap $nLdOverlap 2> $remotePrefix$splitPrefix.err";
        $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
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
	    my $cmd = "\t".&getConf("TABIX")." $invcf $chr:$unitStarts[$j]-$unitEnds[$j] | cut -f 1-8 > $svcfs[$j]\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    print MAK "\ttouch $svcfs[$j].OK\n\n";

	    my @glfs = ();
	    my $smGlfParent = "$remotePrefix$smGlfDirReal/chr$chr/$unitStarts[$j].$unitEnds[$j]";
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
            $glfAlias =~ s/$outDir/\$(OUTPUT_DIR)/g;

	    my $sleepSecs = ($j % 10)*$sleepMultiplier;
	    $cmd = &getConf("GLFEXTRACT")." --invcf $svcfs[$j] --ped $glfAlias -b $vcfs[$j] > $vcfs[$j].log 2> $vcfs[$j].err";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    print MAK "$vcfs[$j].OK: $svcfs[$j].OK ";
	    if ( $expandFlag == 1 ) {
		print MAK join(".OK ",@glfs);
		print MAK ".OK";
	    }
	    print MAK "\n";
#	    print MAK "\tmkdir --p $vcfParent\n";
            if($sleepSecs != 0)
            {
              print MAK "\tsleep $sleepSecs\n";
            }
	    print MAK "\t".&getMosixCmd($cmd)."\n";
	    print MAK "\ttouch $vcfs[$j].OK\n\n";
	}
    }

	#############################################################################
	## STEP 10.5 : RUN SVM FILTERING
	#############################################################################
	if ( &getConf("RUN_SVM") eq "TRUE") {
	    my $vcfParent = "$remotePrefix$vcfDir/chr$chr";
	    my $svcf = "$vcfParent/chr$chr.${filterPrefix}filtered.sites.vcf";
	    my $vcf = "$vcfParent/chr$chr.merged.vcf";

	    my $expandFlag = ( &getConf("RUN_FILTER") eq "TRUE" ) ? 1 : 0;

	    my @cmds = ();

	    my $mvcfPrefix = "$remotePrefix$vcfDir/chr$chr/chr$chr";

	    print MAK "svm$chr: $mvcfPrefix.filtered.vcf.gz.OK\n\n";

	    if ( $expandFlag == 1 ) {
			print MAK "$mvcfPrefix.filtered.vcf.gz.OK: filt$chr\n";
	    }
	    else {
			print MAK "$mvcfPrefix.filtered.vcf.gz.OK: \n";
	    }

		my $cmd = "";
		if (&getConf("USE_SVMMODEL") eq "TRUE")
		{
			$cmd = "\t".&getConf("SVM_SCRIPT")." --invcf $svcf --out $mvcfPrefix.filtered.sites.vcf --model ".&getConf("SVMMODEL")." --svmlearn ".&getConf("SVMLEARN")." --svmclassify ".&getConf("SVMCLASSIFY")." --bin ".&getConf("INVNORM")." --threshold ".&getConf("SVM_CUTOFF")." --bfile ".&getConf("OMNI_VCF")." --bfile ".&getConf("HM3_VCF")." --checkNA \n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
			print MAK "$cmd";
		}
		else
		{
			$cmd = "\t".&getConf("SVM_SCRIPT")." --invcf $svcf --out $mvcfPrefix.filtered.sites.vcf --pos ".&getConf("POS_SAMPLE")." --neg ".&getConf("NEG_SAMPLE")." --svmlearn ".&getConf("SVMLEARN")." --svmclassify ".&getConf("SVMCLASSIFY")." --bin ".&getConf("INVNORM")." --threshold ".&getConf("SVM_CUTOFF")." --bfile ".&getConf("OMNI_VCF")." --bfile ".&getConf("HM3_VCF")." --checkNA \n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
			print MAK "$cmd";
		}
	    $cmd = "\t".&getConf("VCFPASTE")." $mvcfPrefix.filtered.sites.vcf $mvcfPrefix.merged.vcf | ".&getConf("BGZIP")." -c > $mvcfPrefix.filtered.vcf.gz\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    $cmd = "\t".&getConf("TABIX")." -f -pvcf $mvcfPrefix.filtered.vcf.gz\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    $cmd = "\t".&getConf("VCFSUMMARY")." --vcf $mvcfPrefix.filtered.sites.vcf --ref $ref --dbsnp ".&getConf("DBSNP_VCF")." --FNRvcf ".&getConf("HM3_VCF")." --chr $chr --tabix ".&getConf("TABIX")." > $mvcfPrefix.filtered.sites.vcf.summary\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    print MAK "\ttouch $mvcfPrefix.filtered.vcf.gz.OK\n\n";
	    print MAK join("\n",@cmds);
	    print MAK "\n";
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
		#my $cmd = &getConf("VCFPILEUP")." -i $svcf -r $ref -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
		my $cmd = &getConf("VCFPILEUP")." -i $svcf -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
                $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
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
	## STEP 10-5B : HARD FILTERING AFTER MERGING
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
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;

	    my $mvcfPrefix = "$remotePrefix$vcfDir/chr$chr/chr$chr";
	    print MAK "filt$chr: $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n\n";
	    if ( $expandFlag == 1 ) {
		print MAK "$mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK: $gvcf.OK pvcf$chr\n";
	    }
	    else {
		print MAK "$mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK: $gvcf.OK\n";
	    }
	    $cmd = "\t".&getConf("VCFCOOKER")." ".getFilterArgs()." --indelVCF ".&getConf("INDEL_PREFIX").".chr$chr.vcf --out $mvcfPrefix.${filterPrefix}filtered.sites.vcf --in-vcf $gvcf\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    $cmd = "\t".&getConf("VCFPASTE")." $mvcfPrefix.${filterPrefix}filtered.sites.vcf $mvcfPrefix.merged.vcf | ".&getConf("BGZIP")." -c > $mvcfPrefix.${filterPrefix}filtered.vcf.gz\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    $cmd = "\t".&getConf("TABIX")." -f -pvcf $mvcfPrefix.${filterPrefix}filtered.vcf.gz\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    $cmd = "\t".&getConf("VCFSUMMARY")." --vcf $mvcfPrefix.${filterPrefix}filtered.sites.vcf --ref $ref --dbsnp ".&getConf("DBSNP_VCF")." --FNRvcf ".&getConf("HM3_VCF")." --chr $chr --tabix ".&getConf("TABIX")." > $mvcfPrefix.${filterPrefix}filtered.sites.vcf.summary\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    print MAK "\ttouch $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n\n";
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
		    #my $cmd = &getConf("VCFPILEUP")." -i $svcf -r $ref -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
		    my $cmd = &getConf("VCFPILEUP")." -i $svcf -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
                    $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
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
	## STEP 10-5A : HARD FILTERING before MERGING
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
                    $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
		    push(@cmds,"$gvcf.OK: ".join(".OK ",@pvcfs).".OK".(($gmFlag == 1) ? " $vcf.OK" : "")."\n\t".&getMosixCmd($cmd)."\n\ttouch $gvcf.OK\n\n");
		}
		else {
		    my $cmd = &getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]/ --suffix .$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz --outvcf $gvcf --index $bamIndexRemote 2> $gvcf.err";
                    $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
		    push(@cmds,"$gvcf.OK:".(($gmFlag == 1) ? " $vcf.OK" : "")."\n\t".&getMosixCmd($cmd)."\n\ttouch $gvcf.OK\n\n");
		}
		push(@gvcfs,$gvcf);
		push(@vcfs,$vcf);
	    }
	    
	    my $mvcfPrefix = "$remotePrefix$vcfDir/chr$chr/chr$chr";
	    print MAK "filt$chr: $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n\n";
	    print MAK "$mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK: ".join(".OK ",@gvcfs).".OK ".join(".OK ",@vcfs).".OK".(($gmFlag == 1) ? " $mvcfPrefix.merged.vcf.OK" : "")."\n";
	    if ( $#uniqBeds < 0 ) {
              my $cmd = "\t".&getConf("VCFMERGE")." $unitChunk @gvcfs > $mvcfPrefix.merged.stats.vcf\n";
              $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
              print MAK "$cmd";
	    }
	    else {
		print MAK "\t(cat $gvcfs[0] | head -100 | grep ^#; cat @gvcfs | grep -v ^#;) > $mvcfPrefix.merged.stats.vcf\n";
	    }
	    my $cmd = "\t".&getConf("VCFCOOKER")." ".getFilterArgs()." --indelVCF ".&getConf("INDEL_PREFIX").".chr$chr.vcf --out $mvcfPrefix.${filterPrefix}filtered.sites.vcf --in-vcf $mvcfPrefix.merged.stats.vcf\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    $cmd = "\t".&getConf("VCFPASTE")." $mvcfPrefix.${filterPrefix}filtered.sites.vcf $mvcfPrefix.merged.vcf | ".&getConf("BGZIP")." -c > $mvcfPrefix.${filterPrefix}filtered.vcf.gz\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    $cmd = "\t".&getConf("TABIX")." -f -pvcf $mvcfPrefix.${filterPrefix}filtered.vcf.gz\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    $cmd = "\t".&getConf("VCFSUMMARY")." --vcf $mvcfPrefix.${filterPrefix}filtered.sites.vcf --ref $ref --dbsnp ".&getConf("DBSNP_VCF")." --FNRvcf ".&getConf("HM3_VCF")." --chr $chr --tabix ".&getConf("TABIX")." > $mvcfPrefix.${filterPrefix}filtered.sites.vcf.summary\n";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
            print MAK "$cmd";
	    print MAK "\ttouch $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n\n";
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
	    my $smGlfParent = "$remotePrefix$smGlfDirReal/chr$chr/$unitStarts[$j].$unitEnds[$j]";

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
            $glfAlias =~ s/$outDir/\$(OUTPUT_DIR)/g;
	    push(@vcfs,$vcf);
	    my $sleepSecs = ($j % 10)*$sleepMultiplier;
	    my $cmd = &getConf("GLFMULTIPLES")." --ped $glfAlias -b $vcf > $vcf.log 2> $vcf.err";
            $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
	    if ( $expandFlag == 1 ) {
                my $newcmd = "$vcf.OK: ".join(".OK ",@glfs).".OK\n\tmkdir --p $vcfParent\n";
                if($sleepSecs != 0)
                {
                  $newcmd .= "\tsleep $sleepSecs\n";
                }
                $newcmd .= "\t".&getMosixCmd($cmd)."\n\ttouch $vcf.OK\n";
                $newcmd =~ s/$outDir/\$(OUTPUT_DIR)/g;
	 	push(@cmds,"$newcmd");
	    }
	    else {
                my $newcmd = "$vcf.OK:\n\tmkdir --p $vcfParent\n";
                if($sleepSecs != 0)
                {
                  $newcmd .= "\tsleep $sleepSecs\n";
                }
                $newcmd .= "\t".&getMosixCmd($cmd)."\n\ttouch $vcf.OK\n";
                push(@cmds,"$newcmd");
	    }
	}
	my $out = "$vcfDir/chr$chr/chr$chr.merged";
	print MAK "vcf$chr: $remotePrefix$out.vcf.OK\n\n";
	print MAK "$remotePrefix$out.vcf.OK: ";
	print MAK join(".OK ",@vcfs);
	print MAK ".OK\n";
	if ( $#uniqBeds < 0 ) {
          my $cmd = "\t".&getConf("VCFMERGE")." $unitChunk @vcfs > $out.vcf\n";
          $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
          print MAK "$cmd";
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

	my $multiBam = 0;

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
		my $cmd = "$smGlf.OK:";
		$cmd .= (" ".join(".OK ",@bamGlfs).".OK") if ( $#bamGlfs > 0 );
		$cmd .= " bai" if ( &getConf("RUN_INDEX") eq "TRUE" );
		$cmd .= "\n\tmkdir --p $smGlfParent\n\t";
		#my $cmd = "$smGlf.OK:\n\tmkdir --p $smGlfParent\n\t";
		if ( $#bamGlfs > 0 ) {
		    $multiBam = 1;
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
                    $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
		}
		else {
		    #$cmd .= "ln -f -s $bamGlfs[0] $smGlf";
		    my $baqFlag = 1;
		    foreach my $s (@nobaqSubstrings) {
			if ( $bams[0] =~ m/($s)/ ) {
			    $baqFlag = 0;
			}
		    }
		    my $loci = "";
		    my $region = "$chr:$unitStarts[$j]-$unitEnds[$j]";
		    if ( $#uniqBeds >= 0 ) {
			my $idx = $hBedIndices{$allSMs[$i]};
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
			$cmd .= &getMosixCmd("(".&getConf("SAMTOOLS_FOR_OTHERS")." view ".&getConf("SAMTOOLS_VIEW_FILTER")." -uh $bams[0] $region | ".&getConf("BAMUTIL",1)." clipOverlap --in -.bam --out -.ubam | ".&getConf("SAMTOOLS_FOR_PILEUP")." pileup -f $ref $loci -g - > $smGlf) 2> $smGlf.log");
		    }
		    else {
			$cmd .= &getMosixCmd("(".&getConf("SAMTOOLS_FOR_OTHERS")." view ".&getConf("SAMTOOLS_VIEW_FILTER")." -uh $bams[0] $region | ".&getConf("SAMTOOLS_FOR_OTHERS")." calmd -AEbr - $ref 2> /dev/null | ".&getConf("BAMUTIL")." clipOverlap --in -.bam --out -.ubam | ".&getConf("SAMTOOLS_FOR_PILEUP")." pileup -f $ref $loci -g - > $smGlf) 2> $smGlf.log");
		    }
                    $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
		}
		$cmd .= "\n\ttouch $smGlf.OK\n";
		push(@cmds,$cmd);
	    }
	}

	print MAK "glf$chr: ";
	print MAK join(" ",@outs);
	print MAK "\n\n";

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
		    $cmd = &getConf("SAMTOOLS_FOR_OTHERS")." view ".&getConf("SAMTOOLS_VIEW_FILTER")." -uh $bam $region | ".&getConf("BAMUTIL",1)." clipOverlap --in -.bam --out -.ubam | ".&getConf("SAMTOOLS_FOR_PILEUP")." pileup -f $ref $loci -g - > $bamGlf";
		}
		else {
		    $cmd = &getConf("SAMTOOLS_FOR_OTHERS")." view ".&getConf("SAMTOOLS_VIEW_FILTER")." -uh $bam $region | ".&getConf("SAMTOOLS_FOR_OTHERS")." calmd -AEbr - $ref 2> /dev/null | ".&getConf("BAMUTIL")." clipOverlap --in -.bam --out -.ubam | ".&getConf("SAMTOOLS_FOR_PILEUP")." pileup -f $ref $loci -g - > $bamGlf";
		}
                $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
		if ( &getConf("RUN_INDEX") eq "TRUE" ) {
		    push(@cmds,"$bamGlf.OK: bai\n\tmkdir --p $bamGlfDir/$bamSM/chr$chr\n\t".&getMosixCmd("(".$cmd.") 2> $bamGlf.log")."\n\ttouch $bamGlf.OK\n");
		}
		else {
		    push(@cmds,"$bamGlf.OK:\n\tmkdir --p $bamGlfDir/$bamSM/chr$chr\n\t".&getMosixCmd("(".$cmd.") 2> $bamGlf.log")."\n\ttouch $bamGlf.OK\n");
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
        $cmd =~ s/$umakeRoot/\$(UMAKE_ROOT)/g;
        print MAK "$cmd";
	print MAK "$bam.bai.OK:\n\t".&getMosixCmd($cmd)."\n\ttouch $bam.bai.OK\n";
    }
}

close MAK;

print STDERR "--------------------------------------------------------------------\n";
print STDERR "Finished creating makefile $makef\n\n";

my $rc = 0;
if($numjobs != 0) {
  print STDERR "Running $makef\n\n";
  my $cmd = "make -f $makef -j $numjobs > $makef.log";
  my $t = time();
 #           my $rc = 0xffff & system($cmd);
 #           exit($rc);
  system($cmd);
  $rc = ${^CHILD_ERROR_NATIVE};
  $t = time() - $t;
  print STDERR " Commands finished in $t secs";
  if ($rc) { print STDERR " WITH ERRORS.  Check the logs\n"; }
  else { print STDERR " with no errors reported\n"; }
# system($cmd) &&
#    die "Makefile, $makef failed d=$cmd\n";
}
else {

print STDERR "Try 'make -f $makef -n | less' for a sanity check before running\n";
print STDERR "Run 'make -f $makef -j [#parallele jobs]'\n";
}
print STDERR "--------------------------------------------------------------------\n";

exit($rc);

#--------------------------------------------------------------
#   getFilterArgs()
#
#   Returns the filter arguments.
#--------------------------------------------------------------
sub getFilterArgs
{
    my $filterArgs = "--write-vcf --filter";
    my $confValue = getIntConf('FILTER_MAX_SAMPLE_DP');
    if($confValue)
    {
        $filterArgs .= " --maxDP ".($numSamples*$confValue);
    }

    $confValue = getIntConf('FILTER_MIN_SAMPLE_DP');
    if($confValue)
    {
        $filterArgs .= " --minDP ".($numSamples*$confValue);
    }

    # Get the formula min/max sample numbers.
    my $filterMinSamples = getIntConf('FILTER_FORMULA_MIN_SAMPLES');
    if(! $filterMinSamples)
    {
        $filterMinSamples = 100;
    }
    my $filterMaxSamples = getIntConf('FILTER_FORMULA_MAX_SAMPLES');
    if(! $filterMaxSamples)
    {
        $filterMaxSamples = 1000;
    }
    if($filterMinSamples >= $filterMaxSamples)
    {
        die "FILTER_FORMULA_MIN_SAMPLES must be < FILTER_FORMULA_MAX_SAMPLES, but $filterMinSamples >= $filterMaxSamples\n";
    }

    # format of hash value is: 
    # (CONF_NAME, useLogDefault, minDefault, maxDefault)
    # if useLogDefault is set:
    #    min default is the value to use for numSamples < min samples
    #    max default is the value to use for numSamples > max samples
    # if useLogDefault is "", then use minDefault as the default.
    my %filterArgHash = (
                         maxABL => "FILTER_MAX_ABL",
                         maxSTR => "FILTER_MAX_STR",
                         minSTR => "FILTER_MIN_STR",
                         winIndel => "FILTER_WIN_INDEL",
                         maxSTZ => "FILTER_MAX_STZ",
                         minSTZ => "FILTER_MIN_STZ",
                         maxAOI => "FILTER_MAX_AOI",
                         minFIC => "FILTER_MIN_FIC"
                        );
    foreach my $key (sort(keys %filterArgHash))
    {
        my $val = getConf($filterArgHash{$key});
        my $printVal = 0;
        if($val && (lc($val) ne "off"))
        {
            # Check to see if it has multiple values indicating to use
            # the log formula
            my @values = split(/[,\s]+/,$val);
            if(scalar @values > 2)
            {
                die "$key can only have 1 or 2 values, but \"$val\" has ".scalar @values."\n";
            }
            elsif(scalar @values == 1)
            {
                # make sure it is a number.
                if(!looks_like_number($val))
                {
                    die "$key must be set to a number, not \"$val\"";
                }
                $printVal = $val;
            }
            else
            {
                # Make sure both values are numbers
                if(!looks_like_number($values[0]))
                {
                    die "First value in $key must be set to a number, not \"$values[0]\"";
                }
                if(!looks_like_number($values[1]))
                {
                    die "Second value in $key must be set to a number, not \"$values[1]\"";
                }
                if($numSamples < $filterMinSamples)
                {
                    $printVal = $values[0];
                }
                elsif($numSamples > $filterMaxSamples)
                {
                    $printVal = $values[1];
                }
                else
                {
                    my $tempVal = ($values[0] - $values[1]) *
                    (log($filterMaxSamples) - log($numSamples)) /
                    (log($filterMaxSamples) - log($filterMinSamples)) +
                    $values[1];
                    $printVal = sprintf("%.0f",$tempVal);
                }
            }
            $filterArgs .= " --$key $printVal";
        }
    }

    return $filterArgs;
}


#--------------------------------------------------------------
#   setConf(key, value, force)
#
#   Sets a value in a global hash (%hConf) to save the value
#   for various key=value pairs. First key wins, so if a
#   second key is provided, only the value for the first is kept.
#   If $force is specified, we change the conf value even if
#   it is set.
#--------------------------------------------------------------
sub setConf {
    my ($key, $value, $force) = @_;
    if (! defined($force)) { $force = 0; }

    if ((! $force) && (defined($hConf{$key}))) { return; }
    #   Why manage keys for a has manually ??
    if (! defined($hConf{$key})) { push (@keys, $key); }
    $hConf{$key} = $value;
}

#--------------------------------------------------------------
#   loadLine(line)
#
#   Parse the specified configuration line, extracting key=value data
#   Will not return on errors
#--------------------------------------------------------------
sub loadLine
{
    return if ( /^#/ );  # ignore lines that start with # (comment lines)
    return if (/^\s*$/); # Ignore blank lines
    s/#.*$//;          # trim in-line comment lines starting with #
    my ($key,$val);
    if ( /^\s*(\w+)\s*=\s*(.*)\s*$/ ) {
        ($key,$val) = ($1,$2);
        $key =~ s/^\s+//;  # remove leading whitespaces
        $key =~ s/\s+$//;  # remove trailing whitespaces
        $val =~ s/^\s+//;
        $val =~ s/\s+$//;
    }
    else {
        die "Cannot parse line $_ at line $.\n"; # removed "in $conf"
    }

    # Skip if the key has already been defined.
    return if ( defined($hConf{$key}) );

    if ( !defined($val) ) {
        $val = "";     # if value is undefined, set it as empty string
    }

    # check if predefined key exist and substitute it if needed
    while ( $val =~ /\$\((\S+)\)/ ) {
        my $subkey = $1;
        my $subval = &getConf($subkey);
        if ($subval eq "") {
            die "Cannot parse configuration value $val at line $., $subkey not previously defined\n";
        }
        $val =~ s/\$\($subkey\)/$subval/;
    }
    setConf($key, $val);
}


#--------------------------------------------------------------
#   loadConf(config)
#
#   Read a configuration file, extracting key=value data
#   Calls loadLine(line)
#   Will not return on errors
#--------------------------------------------------------------
sub loadConf {
    my $conf = shift;

    my $curPath = getcwd();

    open(IN,$conf) || die "Cannot open $conf file for reading, from $curPath";
    while(<IN>) {
	&loadLine($_);
    }
    close IN;
}


#--------------------------------------------------------------
#   loadOveride(commands)
#
#   Read the passed in overide string of configuration overrides,
#   extracting extracting key=value data separated by ';'
#   Calls loadLine(line)
#   Will not return on errors
#--------------------------------------------------------------
sub loadOverride {
my $commands = shift;
my @commlist = split(";",$commands);
foreach (@commlist) {
 &loadLine($_);
 }
}


#--------------------------------------------------------------
#   value = getIntConf(key, required)
#
#   Calls into getConf with the specified parameters, but if set,
#   verifies it is a number.
#--------------------------------------------------------------
sub getIntConf {
    my ($key, $required) = @_;
    my $val = getConf($key, $required);

    if($val)
    {
        die "$key can only be set to a number, not $val" unless (looks_like_number($val));
    }
    return $val;
}


#--------------------------------------------------------------
#   value = getConf(key, required)
#
#   Gets a value in a global hash (%hConf).
#   If required is not TRUE and the key does not exist, return ''
#   If required is TRUE and the key does not exist, die
#--------------------------------------------------------------
sub getConf {
    my ($key, $required) = @_;
    if (! defined($required)) { $required = 0; }

    if (! defined($hConf{$key}) ) {
        if (! $required) { return '' }
        die "Required key '$key' not found in configuration files\n";
    }

    my $val = $hConf{$key};
    #   Substitute for variables of the form $(varname)
    foreach (0 .. 50) {             # Avoid infinite loop
        if ($val !~ /\$\((\S+)\)/) { last; }
        my $subkey = $1;
        my $subval = getConf($subkey);
        if ($subval eq '' && $required) {
            die "Unable to substitue for variable '$subkey' in configuration variable.\n" .
                "  key=$key\n  value=$val\n";
        }
        $val =~ s/\$\($subkey\)/$subval/;
    }
    return $val;
}

#--------------------------------------------------------------
#   parseTarget() : Read UCSC BED format as target information 
#                   allowing a certain offset from the target
#                   merge overlapping extended intervals if possible
#--------------------------------------------------------------
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
## getMosixCmd() : convert a command to mosix command
############################################################################
sub getMosixCmd {
    my $cmd = shift;

    if ( ($batchtype eq "") || ($batchtype eq "local") )
    {
	return $cmd;
    }
    else
    {
      $cmd =~ s/'/"/g;            # Avoid issues with single quotes in command
      my $newcmd = $runcluster." ";
      if($batchopts)
      {
        $newcmd .= "-opts '".$batchopts."' ";
      }
      $newcmd .= "$batchtype '$cmd'";
      return $newcmd;
    }
}

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

umake.pl - Preform variant calling, generating VCF

=head1 SYNOPSIS

  umake.pl -test ~/testumake    # Run short self check
  umake.pl -conf ~/mydata.conf -outdir ~/testdir
  umake.pl -batchtype slurm -conf ~/mydata.conf


=head1 DESCRIPTION

Use this program to generate a Makefile which will run the programs
to perform variant calling to generate a single VCF for all samples.

There are many inputs to this script which are most often specified in a
configuration file.

The official documentation for this program can be found at
B<http://genome.sph.umich.edu/wiki/Variant_Calling_Pipeline_(UMAKE)>

There are command line options which may be used to specify certain values
in the configuration file.
Command line options override values specified in the configuration file.

When running in a batch environment (option B<batchtype>) it will be
important to use paths for files which are valid in the cluster environment also.
The path to your HOME (e.g. /home/myuser) may not be valid in the machine in the cluster.
It i<may> be sufficent to specify an alternative path by setting the HOME environment
variable to something valid for the cluster (e.g. I<export HOME=/net/gateway/home/myuser>).


=head1 INPUT FILES

The B<configuration file> consists of a set of keyword = value lines which define variables.
These variables can be referenced in the values of other lines.
This short example will give you an idea of a configuration file:

  CHRS = 20
  BAM_INDEX = indexFile.txt
  # References
  REF_ROOT = $(TEST_ROOT)/ref
  REF = $(REF_ROOT)/karma.ref/human.g1k.v37.chr20.fa
  INDEL_PREFIX = $(REF_ROOT)/indels/1kg.pilot_release.merged.indels.sites.hg19
  DBSNP_VCF =  $(REF_ROOT)/dbSNP/dbsnp135_chr20.vcf.gz
  HM3_VCF =  $(REF_ROOT)/HapMap3/hapmap_3.3.b37.sites.chr20.vcf.gz

The B<bam index> file specifies information about individuals and paths to
bam data. The data is tab delimited.

=head1 OPTIONS

=over 4

=item B<-conf file>

Specifies the configuration file to be used.
The default configuration is B<umakeDefaults.conf> found in the same directory
where this program resides.
If this file is not found, you must specify this option on the command line.

=item B<-dry-run>

If specified no commands will actually be executed, but you will be shown
the commands that would be run.

=item B<-help>

Generates this output.

=item B<-nowait>

Do not wait for the tasks that were submitted to the cluster to end.
This is forced when B<batchtype pbs> is specified.

=item B<-numjobs N>

The value of the B<-j> flag for the make command.
If not specified, the flag is not set on the make command to be executed.

=item B<-outdir dir>

Specifies the toplevel directory where the output is created.

=item B<-test outdir>

Run a small test case putting the output in the directory B<outdir> and verify the output.

=back

=head1 PARAEMETERS

The program accepts no parameters - all input is specified as options.

=head1 EXIT

If no fatal errors are detected, the program exits with a
return code of 0. Any error will set a non-zero return code.

=head1 AUTHOR

Written by Mary Kate Wing I<E<lt>mktrost@umich.eduE<gt>>.
This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; See http://www.gnu.org/copyleft/gpl.html

=cut

