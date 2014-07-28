#!/usr/bin/perl
#################################################################
#
# Name: pipeline.pl
#
# Description:
#   Use this to generate a makefile for generic pipelines.
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd;
use Cwd 'abs_path';
#use Devel::Size qw(size total_size);
#use Time::HiRes qw(gettimeofday);
#use Memory::Usage;

#my $mu = Memory::Usage->new();

#   Find out where this program lives (in a 'bin' directory).
#   Symlinks are tricky
$_ = abs_path($0);
my ($me, $scriptdir, $mesuffix) = fileparse($_, '\.pl');
$scriptdir = abs_path($scriptdir);
my $gotcloudRoot = $scriptdir;
if ($scriptdir =~ /(.*)\/bin/) { $gotcloudRoot = $1; }

push @INC,$scriptdir;                   # Use lib is a BEGIN block and does not work

#############################################################################
#   Global Variables
############################################################################

#--------------------------------------------------------------
#   Initialization - Sort out the options and parameters
#--------------------------------------------------------------
my %opts = (
    runcluster => '',
    pipelinedefaults => '',
    phonehome => '',
    noPhoneHome => '',
    calcstorage => '',
    keeptmp => 0,
    keeplog => 0,
    conf => '',
    verbose => 0,
    maxlocaljobs => 10,
);
Getopt::Long::GetOptions( \%opts,qw(
    help
    name=s
    dry-run|dryrun
    batchtype=s
    batchopts=s
    test=s
    out_dir|outdir=s
    conf=s
    bam_index|bamindex=s
    ref_dir|refdir=s
    ref_prefix|refprefix=s
    bam_prefix|bamprefix=s
    base_prefix|baseprefix=s
    chrs|chroms=s
    keeptmp
    keeplog
    verbose=i
    numjobs|numjobs=i
    maxlocaljobs=i
    gotcloudroot|gcroot=s
    region=s
)) || die "Failed to parse options\n";

#   Simple help if requested, sanity check input options
if ($opts{help}) {
    warn "$me$mesuffix [options]\n" .
        "Use this to generate a makefile for indel calling.\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}

#--------------------------------------------------------------
#   Check for GOTCLOUD_ROOT in the conf files.
#--------------------------------------------------------------
# Check the conf file for GOTCLOUD_ROOT
my @configs = split(' ', $opts{conf});
if(!$opts{gotcloudroot})
{
    foreach my $file (@configs)
    {
        my $fileContents;
        open my $openFile, '<', $file or die "$!, $file";
        $fileContents = <$openFile>;
        close $openFile;
        if(!defined $fileContents)
        {
            die "ERROR: The gotcloud configuration file, '$file', is empty.\n";
        }
        if ($fileContents =~ m/^\s*GOTCLOUD_ROOT\s*=\s*(.*)/)
        {
            $opts{gotcloudroot} = "$1";
            last;
        }
    }
}

if($opts{gotcloudroot})
{
    $gotcloudRoot = $opts{gotcloudroot};
    $scriptdir = "$gotcloudRoot/bin/";
    push @INC,$scriptdir;
}
require GC_Common;
require Conf;
#require Multi;

my @confSettings;
push(@confSettings, "GOTCLOUD_ROOT = $gotcloudRoot");

#--------------------------------------------------------------
#   Check if we are running the test case.
#--------------------------------------------------------------
if ($opts {test}) {
    # remove a trailing slash if there is one.
    $opts{test} =~ s/\/\z//;
    my $outdir=abs_path($opts{test});
    system("mkdir -p $outdir") &&
        die "Unable to create directory '$outdir'\n";
    my $testoutdir = $outdir . "/$opts{name}test";
    print "Removing any previous results from: $testoutdir\n";
    system("rm -rf $testoutdir") &&
        die "Unable to clear the test output directory '$testoutdir'\n";
    print "Running GOTCLOUD TEST, test log in: $testoutdir.log\n";
    my $testdir = $gotcloudRoot . "/test/umake";
    if(! -r $testdir)
    {
        die "ERROR, '$testdir' does not exist, please download the test data to that directory\n";
    }
    my $cmd = "$0 --name $opts{name} -conf $testdir/umake_test.conf -out $testoutdir --numjobs 2";
    if($opts{gotcloudroot})
    {
        $cmd .= " --gotcloudRoot $gotcloudRoot";
    }
    system($cmd) &&
        die "Failed to generate test data. Not a good thing.\nCMD=$cmd\n";
    $cmd = "$gotcloudRoot/scripts/diff_results_indel.sh $outdir $gotcloudRoot/test/indel/expected";
    system($cmd) &&
        die "Comparison failed, test case FAILED.\nCMD=$cmd\n";
    print "Successfully ran the test case, congratulations!\n";
    exit;
}


#############################################################################
#   Set defaults for command-line options if they weren't set.
#############################################################################
if(!$opts{runcluster})
{
    $opts{runcluster} = "$gotcloudRoot/scripts/runcluster.pl",
}
$opts{runcluster} = abs_path($opts{runcluster});    # Make sure this is fully qualified

if(!$opts{pipelinedefaults})
{
    $opts{pipelinedefaults} = "$gotcloudRoot/bin/gotcloudDefaults.conf";
}
if(!$opts{phonehome})
{
    $opts{phonehome} = "$gotcloudRoot/scripts/gcphonehome.pl -pgmname GotCloud $me";
}
if(!$opts{calcstorage})
{
    $opts{calcstorage} = "$gotcloudRoot/scripts/gccalcstorage.pl $me";
}


if ((! $opts{conf}) || (! -r $opts{conf})) {
    my $usage;
    if($opts{conf})
    {
        $usage .= "Conf file '$opts{conf}' does not exist or was not specified\n";
    }
    $usage .= "Usage:\tgotcloud --name $opts{name} --conf [conf.file]\n".
    "Specify --help to get more usage infromation\n";
    die "$usage";
}
$opts{conf} = abs_path($opts{conf});

#############################################################################
#   Set configuration variables from comand line options
#############################################################################
if ($opts{out_dir}) {
    # remove a trailing slash if there is one.
    $opts{out_dir} =~ s/\/\z//;
    my $outdir = abs_path($opts{out_dir});
    system("mkdir -p $outdir") &&
        die "Unable to create directory '$outdir'\n";
    # Add the output directory to the configuration.
    push(@confSettings, "OUT_DIR = $outdir");
}

my $ref_dir = '';
if ($opts{ref_dir}) {
    $ref_dir = abs_path($opts{ref_dir});
    push(@confSettings, "REF_DIR = $ref_dir");
}

#   Set the configuration values for applicable command-line options.
if ($opts{ref_prefix})   { push(@confSettings, "REF_PREFIX = $opts{ref_prefix}"); }
if ($opts{bam_prefix})   { push(@confSettings, "BAM_PREFIX = $opts{bam_prefix}"); }
if ($opts{base_prefix})  { push(@confSettings, "BASE_PREFIX = $opts{base_prefix}"); }
if ($opts{keeptmp})      { push(@confSettings, "KEEP_TMP = $opts{keeptmp}"); }
if ($opts{keeplog})      { push(@confSettings, "KEEP_LOG = $opts{keeplog}"); }
if ($opts{bam_index})    { push(@confSettings, "BAM_INDEX = $opts{bam_index}"); }
if ($opts{chrs})         { $opts{chrs} =~ s/,/ /g; push(@confSettings, "CHRS = $opts{chrs}"); }
if ($opts{batchtype})    { push(@confSettings, "BATCH_TYPE = $opts{batchtype}"); }
if ($opts{batchopts})    { push(@confSettings, "BATCH_OPTS = $opts{batchopts}"); }

#############################################################################
#   Load configuration variables from conf file
#   Load config values. The default conf file is almost never seen by the user,
push(@configs, $opts{pipelinedefaults});

if (loadConf(\@confSettings, \@configs, $opts{verbose})) {
    die "Failed to read configuration files\n";
}

#-------------
# Handle cluster setup.
# Pull batch info from config if not on command line.
if ((!defined $opts{batchopts}) || ( $opts{batchopts} eq "" )) {
    $opts{batchopts} = getConf("BATCH_OPTS");
}
if ((!defined $opts{batchtype}) || ( $opts{batchtype} eq "" )) {
    $opts{batchtype} = getConf("BATCH_TYPE");
}
if ((!defined $opts{batchtype}) || ($opts{batchtype} eq ""))
{
    $opts{batchtype} = "local";
}
if ($opts{batchtype} eq 'flux') { $opts{batchtype} = 'pbs'; }

#--------------------------------------------------------------
#   Check required settings
#--------------------------------------------------------------

if((!defined $opts{name}) || ($opts{name} eq ""))
{
    die "ERROR: '--name' is required, but not set.\n";
}

my $failReqFile = "0";
if(!getConf("BAM_INDEX"))
{
    warn "ERROR: 'BAM_INDEX' required, but not set.\n";
    $failReqFile = "1";
}

if($failReqFile eq "1")
{
    die "Exiting pipeline due to required file(s) missing\n";
}

my $newpath = getAbsPath(getConf("REF"), "REF");
setConf("REF", $newpath);

# TODO check for file existence
# determine what references it needs.

#############################################################################
## STEP  : Parse BAM INDEX FILE
############################################################################
my $bamIndex = getAbsPath(getConf("BAM_INDEX"));
my %sample2bams = ();  # hash mapping sample IDs to bams
my %sample2SingleBam = ();  # hash mapping sample IDs to a single per sample bam
my %bam2sample = ();  # hash mapping bams to sample IDs
my %samples = ();

# TODO -for now to ease comparison with previous results, also store the arrays
my @samplesArray = ();
my %singleBamSamples = ();
my %multiBamSamples = ();
my @singleBamSamplesArray = ();
my @multiBamSamplesArray = ();

open(INDEX,$bamIndex) || die "Cannot open $bamIndex file\n";
while (<INDEX>)
{
    chomp;
#    s/\r?\n?$//;
    if(!/^#/)
    {
        my ($sampleID, $pop, @bams) = split;
        next if(!defined $sampleID); # Skip empty line
        # fail if there are no BAMs specified.
        if(scalar(@bams) == 0)
        {
            die "ERROR: SampleID $sampleID in $bamIndex has no bams\n";
        }
        # Check if the sample already exists.
        if(defined $sample2bams{$sampleID})
        {
            die "ERROR: Duplicate SampleID $sampleID in $bamIndex\n".
            "All BAMs for a SampleID should be on one line\n";
        }

        # Process each bam
        foreach my $bam (@bams)
        {
            # check if it starts with a configuration value.
            while($bam =~ /\$\(([^\s)]+)\)/ )
            {
                my $key = $1;
                my $val = getConf($key);
                $bam =~ s/\$\($key\)/$val/;
            }

            # Check if there is just a relative path to the bams.
            if ( !( $bam =~ /^\// ) )
            {
                # It is relative, so make it absolute.
                $bam = getAbsPath($bam, "BAM");
            }
            $bam2sample{$bam} = $sampleID;
        }

        $sample2bams{$sampleID} = \@bams;
        if(scalar @bams == 1)
        {
            $sample2SingleBam{$sampleID} = $bams[0];
            $singleBamSamples{$sampleID} = undef;
            push(@singleBamSamplesArray, $sampleID);
        }
        else
        {
            $sample2SingleBam{$sampleID} = undef;
            $multiBamSamples{$sampleID} = undef;
            push(@multiBamSamplesArray, $sampleID);
        }
        $samples{$sampleID} = undef;
        push(@samplesArray, $sampleID);
    }
}
close(INDEX);



#############################################################################
## STEP 4 : Read FASTA INDEX file to determine chromosome size
############################################################################
my %hChrSizes = ();
my $ref = getConf("REF");
my $fai = $ref.".fai";
if(getConf("REF_FAI"))
{
    $fai = getConf("REF_FAI");
}

open(IN,$fai) || die "Cannot open $fai file for reading";
while(<IN>) {
    my ($chr,$len) = split;
    $hChrSizes{$chr} = $len;
}
close IN;

# TODO
my ($callstart,$callend);
if ( $opts{region} ) {
    if ( $opts{region} =~ /^([^:]+):(\d+)(\-\d+)?$/ ) {
# TODO - set CHRS to $1        @chrs = ($1);
        $callstart = $2;
        $callend = $3 ? substr($3,1) : $hChrSizes{$1};
        print STDERR "Call region is $1:$callstart-$callend\n";
    }
    else {
        die "Cannot recognize option --region $opts{region}\nExpected format: N:N-N\n";
    }
}


############################################################################
# PARSE TARGET INFORMATION if specified
############################################################################
my $multiTargetMap = getConf("MULTIPLE_TARGET_MAP");
my $uniformTargetBed = getConf("UNIFORM_TARGET_BED");


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
#    for(my $i=0; $i < @samples; ++$i)
    foreach my $sample (sort(keys(%samples)))
    {
        $hBedIndices{$sample} = 0;
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

    foreach my $sample (sort(keys(%samples)))
    {
        die "Cannot find target information for sample $sample\n" unless (defined($hSM2BedIndex{$sample}));
        $hBedIndices{$sample} = $hSM2BedIndex{$sample};
    }
}

foreach my $bed (@uniqBeds) {
    my $r = parseTarget($bed,getConf("OFFSET_OFF_TARGET"));
    push(@targetIntervals,$r);
}

############################################################################
# DETERMINE THE CHR REGIONS
############################################################################
my %regions = ();

my @chrs = split(/\s+/,getConf("CHRS"));
my $unitChunk = getStepConf($opts{name},"UNIT_CHUNK");
foreach my $chr (@chrs)
{
    if(! defined $hChrSizes{$chr})
    {
        warn "skipping $chr, since it is not in the reference\n";
        # add no regions.
        my @tmpReg;
        push(@{$regions{$chr}}, @tmpReg);
        next;
    }
    for(my $j=0; $j < $hChrSizes{$chr}; $j += $unitChunk)
    {
        my $start = sprintf("%d",$j+1);
        my $end = ($j+$unitChunk > $hChrSizes{$chr}) ? $hChrSizes{$chr} : sprintf("%d",$j+$unitChunk);

        ## if --region was specified, check overlap and skip if necessary
        next if ( defined($callstart) && ( ( $start > $callend ) || ( $end < $callstart ) ) );

        # if targeted sequencing, check if the region overlaps
        # with any of the known targets
        my $inTarget = ($#uniqBeds < 0) ? 1 : 0;
        if ( $inTarget == 0 ) {
            for(my $k=0; ($k < @uniqBeds) && ( $inTarget == 0) ; ++$k) {
                foreach my $p (@{$targetIntervals[$k]->{$chr}}) {
                    # check if any of target overlaps
                    unless ( ( $p->[1] < $start ) || ( $p->[0] > $end ) ) {
                        $inTarget = 1;
                        last;
                    }
                }
            }
        }
        if ( $inTarget == 1 ) {
            my @tmpReg = [$start, $end];
            push(@{$regions{$chr}}, @tmpReg);
        }
    }
}

#############################################################################
## Create MAKEFILE
############################################################################
my $outdir = getConf("OUT_DIR");
unless ( $outdir =~ /^\// ) {
    $outdir = getcwd()."/".$outdir;
    setConf('OUT_DIR', $outdir);
}

system("mkdir -p $outdir") &&
die "Unable to create directory '$outdir'\n";
my $makeBase = "$outdir/".getConf("MAKE_BASE_NAME_PIPE").".indel";
dumpConf("$makeBase.conf");
my $makef = "$makeBase.Makefile";

open(MAK,">$makef") || die "Cannot open $makef for writing\n";
#print MAK "OUT_DIR=$outdir\n";
#print MAK "GOTCLOUD_ROOT=$gotcloudRoot\n\n";
print MAK ".DELETE_ON_ERROR:\n";
print MAK ".DEFAULT_GOAL := all\n\n";
#print MAK "all:";
#foreach my $chr (@chrs) {
#    print MAK " all$chr";
#}
#print MAK "\n\n";


#############################################################################
#   TMP Variables
############################################################################
my %tmpVals = ();
my %allowedTmpVals = (BAM=>1, SAMPLE=>1);

#############################################################################
#   Start INDEL specific part.
my $stepTargets = "";

my @steps = split(' ', getStepConf($opts{name},"STEPS", 1));

my %allDirs = ();
my %allStepInfo;

print MAK "all: @steps\n";
foreach my $step (@steps)
{
    setupStepSettings($step);
}

foreach my $step (@steps)
{
    # Reset the TMP values for the new step.
#    my $start = Time::HiRes::gettimeofday();
    undef %tmpVals;
#    %tmpVals = ();
#    $mu->record("starting $step");

    handleStep($step, getStepInfo($step, "TYPE"), \&processTarget);

#    $mu->record("after $step");
#    print "$step, tmpVals size = ".total_size(\%tmpVals)."\n";
#    my $end = Time::HiRes::gettimeofday();
#    printf("$step : %.2f\n", $end - $start);

    print MAK "$step:".$stepTargets."\n\n";

    # Clear the targets.
#print "allStepTarget Size1 = ".total_size(\$stepTargets)."\n";
    $stepTargets = undef;
    $stepTargets = "";
#print "allStepTarget Size2 = ".total_size(\$stepTargets)."\n";
    undef $tmpVals{"INPUT"};
}
#    $mu->dump();

#############################################################################
#   Write Directory Targets
############################################################################
foreach my $dir (sort(keys %allDirs))
{
    writeMake("$dir:\n\tmkdir -p $dir\n\n");
}
#print "allStepInfo size = ".total_size(\%allStepInfo)."\n";

#############################################################################
#   Close the Makefile
############################################################################
close MAK;



print STDERR "--------------------------------------------------------------------\n";
print STDERR "Finished creating makefile $makef\n\n";

my $rc = 0;
if($opts{numjobs} && ($opts{numjobs} != 0)) {
    my $cmd = "make -k -f $makef -j $opts{numjobs} ". getConf("MAKE_OPTS") . " > $makef.log";
    if(($opts{batchtype} eq 'local') && ($opts{numjobs} > $opts{maxlocaljobs}))
    {
        die "ERROR: can't run $opts{numjobs} jobs with 'BATCH_TYPE = local', " .
            "max is $opts{maxlocaljobs}\n" .
            "Rerun with a different 'BATCH_TYPE' or override the local maximum ".
            "using '--maxlocaljobs $opts{numjobs}'\n" .
            "#  These commands would have been run:\n" .
            "  $cmd\n";
    }

    print STDERR "Running: $makef\n";
    print STDERR "Logging to: $makef.log\n\n";
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
    print STDERR "Try 'make -f $makef ". getConf("MAKE_OPTS") . " -n | less' for a sanity check before running\n";
    print STDERR "Run 'make -k -f $makef ". getConf("MAKE_OPTS") . " -j [#parallele jobs]'\n";
}
print STDERR "--------------------------------------------------------------------\n";

exit($rc >> 8);



#############################################################################
#   END MAIN
############################################################################


sub testloop
{
    my $output = resolveTmp(getStepInfo("indexD", "OUTPUT"));
my @deps;
    getOutputs("discover", \@deps);
    my $output1 = resolveTmp(getStepInfo("discover", "OUTPUT"));
#setTmp("BAM", "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
    my $output2 = resolveTmp(getStepInfo("indexD", "CMD"));
    writeTarget($output, $output1, $output2);
}


#--------------------------------------------------------------
# handleStep(step, type)
# Process this step, looping as necessary through Chr, Region,
# Sample, BAM using recursion.
#--------------------------------------------------------------
sub handleStep
{
    # Get the step
    my ($step, $type, $function, @args) = @_;

    #####################################################################
    # Check for necessary recursion for each CHR, START/END, SAMPLE, BAM
    if(($type =~ /PerChr/) && (!defined $tmpVals{"CHR"}))
    {
        for my $chr (@chrs)
        {
            setTmp("CHR", $chr);
            handleStep(@_);
        }
        rmTmp("CHR");
        return;
    }
    if(($type =~ /PerRegion/) && (!defined $tmpVals{"START"}))
    {
        my $chr = $tmpVals{"CHR"};
        for(my $index = 0; $index < scalar(@{$regions{$chr}}); ++$index)
        {
            my $start = $regions{$chr}[$index][0];
            my $end = $regions{$chr}[$index][1];
            setTmp("START", $start);
            setTmp("END", $end);
            handleStep(@_);
        }

        rmTmp("START");
        rmTmp("END");
        return;
    }
    if(($type =~ /PerSample/) && (!defined $tmpVals{"SAMPLE"}))
    {
        #for my $sample (@samples)
#        foreach my $sample (sort(keys(%{$allStepInfo{$step}{SAMPLES}})))
        for my $sample (@{$allStepInfo{$step}{SAMPLES_ARRAY}})
        {
            setTmp("SAMPLE", $sample);
            handleStep(@_);
        }
        rmTmp("SAMPLE");
        return;
    }
    if(($type =~ /PerBam/) && (!defined $tmpVals{"BAM"}))
    {
        # SAMPLE is always defined.
        foreach my $bam (@{$sample2bams{$tmpVals{"SAMPLE"}}})
        {
            setTmp("BAM", $bam);
            handleStep(@_);
        }
        rmTmp("BAM");
        return;
    }
    $function->($step, @args);
}


sub processTarget
{
    my ($step) = @_;
    my $makeDepends = "";
    my @inputs = ();
#    my $inputs;

#    handleDepends($step, \$makeDepends, \$inputs);
    handleDepends($step, \$makeDepends, \@inputs);

#if($step eq "fileList")
#{
#print "makeDepends size = ".total_size(\$makeDepends)."\n";
#print "inputs size = ".total_size(\@inputs)."\n";
#}
    # Run something if:
    #   1) there are inputs to be processed OR no dependencies
    #  AND
    #   2) MULTI is not specified OR there are multiple inputs
    #  AND
    #   3) SINGLE is not specified OR there is 1 input
    my $inputsSize = scalar(@inputs);
    if ((($inputsSize != 0) || getStepInfo($step, "DEPEND") eq "") &&
        ((getStepInfo($step, "MULTI_ONLY") eq "") ||
         ($inputsSize > 1)) &&
        ((getStepInfo($step, "SINGLE_ONLY") eq "") ||
         ($inputsSize == 1)))
    {
        # Process this step.
        # First set, the INPUT to all the inputs.
        setTmp("INPUT", join(" ".getStepInfo($step, "INPUT_JOIN")." ",
                             @inputs));

        my $output = resolveTmp(getStepInfo($step,"OUTPUT"));
        # Write the Makefile Target for this step.
        writeTarget($output, $makeDepends,
                    resolveTmp(getStepInfo($step, "CMD")));
        $stepTargets .= " ".$output.".OK";

        # if we are generating a file containing the outputs, write to it.
        if(getStepConf($step, "FILELIST"))
        {
            my $filelist = resolveTmp(getStepConf($step, "FILELIST"));
            my ($fileName, $dir) = fileparse($filelist);
            system("mkdir -p $dir") &&
            die "Unable to create directory '$dir'\n";
            open(my $fh, '>>', $filelist)
            or die "Unable to append to $filelist\n$!\n";
            print $fh "$output\n";
            close $fh;
        }
    }
}


sub handleDepends
{
    my ($step, $makeDependsRef, $inputRef) = @_;

    my $sample = $tmpVals{"SAMPLE"};
    ####################################
    # Get the dependencies.
    foreach my $depend (@{$allStepInfo{$step}{DEPEND}})
    {
        my $joinVal = getStepConf($step, "${depend}_JOIN");
        if(($depend eq "BAM") || ($depend eq "PER_SAMPLE_BAM"))
        {
            my @depBams = ();
            if(getStepInfo($step, "TYPE") !~ /PerBam/)
            {
                # Loop through the bams.
                if(defined $sample)
                {
                    # Only this sample
                    if($depend eq "PER_SAMPLE_BAM")
                    {
                        @depBams = $sample2SingleBam{$sample};
                    }
                    else
                    {
                        # Only depends on all bams for this sample.
                        @depBams = @{$sample2bams{$sample}};
                    }
                }
                else
                {
                    # depends on all bams
                    if($depend eq "PER_SAMPLE_BAM")
                    {
                        @depBams = (sort values %sample2SingleBam);
                    }
                    else
                    {
                        @depBams = (keys %bam2sample);
                    }
                }
            }
            else
            {
                push(@depBams, getTmp("BAM"));
            }
            foreach my $bam (@depBams)
            {
                if(!exists $bam2sample{$bam})
                {
                    $$makeDependsRef .= " ${bam}.OK";
                }
                elsif(getStepInfo($step, "BAM_DEPEND"))
                {
                    $$makeDependsRef .= $bam;
                }
#                $$inputRef .= $bam;
                push(@{$inputRef}, $bam);
            }
            setTmp("${depend}/OUTPUT", join(" $joinVal ", @depBams));
            setTmp("BAM", join(" $joinVal ", @depBams));
        }
        else
        {
            # check if this is for a sample and the dependency supports
            # that sample.
            if((defined $sample) &&
               (!exists ${allStepInfo}{$depend}{"SAMPLES"}->{$sample}))
            {
                # go to the next dependency since this dependency is N/A
                # for this sample.
                next;
            }
            my @depInputs = ();
#            handleStep($depend, getStepInfo($depend, "TYPE"),
#                       \&getOutputs, \@depInputs);
            handleStep($depend, getStepInfo($depend, "TYPE"),
                       \&getOutputs, \@depInputs);

#if($step eq "fileList")
#{
#print "depInputs size = ".total_size(\@depInputs)."\n";
#}
            if(scalar(@depInputs) >= 1)
            {
                push(@{$inputRef}, @depInputs);
#                $$inputRef .= @depInputs;
                $$makeDependsRef .= " ".join(".OK ", @depInputs).".OK";
            }
            setTmp("${depend}/OUTPUT", join(" $joinVal ", @depInputs));
        }
    }
}


#--------------------------------------------------------------
#   cmd = getOutputs(step)
#
# Get the output filename for this step based on the already 
# set SAMPLE, BAM, CHR, START, and END.
# Return all of the outputs (concatenating the recursive calls)
# as a " " separated list.
#--------------------------------------------------------------
sub getOutputs
{
    my ($step, $retRef) = @_;

    ####################################################################
    # CHR, REGION, SAMPLE, BAM set as neccessary, so now get the output
    my $output = getStepInfo($step, "OUTPUT");
    $output = resolveTmp($output);

    # Not all outputs were kept, so check to see if this output was created.
    push(@{$retRef}, $output);
}

#--------------------------------------------------------------
#   getStepType ( step )
#   Returns the type of command to be run... PerRegionPerChr, etc
#--------------------------------------------------------------
sub getStepType
{
    my ($step) = @_;

    # OUTPUT is required
    my $output = getStepConf($step,"OUTPUT", 1);
    my $outputtype = "One";

    if(hasTmpKey($output, "BAM"))    { $outputtype .= "PerBamPerSample"; }
    elsif(hasTmpKey($output, "SAMPLE")) { $outputtype .= "PerSample"; }
    if(hasTmpKey($output, "CHR"))    { $outputtype .= "PerChr"; }
    if(hasTmpKey($output, "START"))  { $outputtype .= "PerRegion"; }

# TODO check for any other tmp keys - invalid.
    # Check for valid types - can't have PerRegion without PerChr.
    die "ERROR, can't have a PerRegion type without PerChr\n" if(($outputtype =~ /PerRegion/) && ($outputtype !~ /PerChr/));
    return($outputtype);
}

###############################################################
#--------------------------------------------------------------
# TmpKey/Configuration processing
#--------------------------------------------------------------
###############################################################

#--------------------------------------------------------------
#   hasTmpKey ( string, key )
# Checks if the string has the temporary value key in it.
# Returns true if it has the key, false if not.
#--------------------------------------------------------------
sub hasTmpKey
{
    my ($string, $key) = @_;
    return($string =~ m/\?\($key\)/);
}

#--------------------------------------------------------------
#   setTmp ( key, value )
# Set the specified temporary key with the specified value.
# Validates that key is an allowed tmp (dies if it is not allowed).
#--------------------------------------------------------------
sub setTmp {
    my ($key, $value) = @_;

    # Check list of keys that can be added.
    if(!defined ($allowedTmpVals{$key}))
    {
  #      die "ERROR: '$key' cannot be a temporary value\n";
    }
    $tmpVals{$key} = $value;
}

#--------------------------------------------------------------
#   appendTmp ( key, value )
# Set the specified temporary key with the specified value.
# Validates that key is an allowed tmp (dies if it is not allowed).
#--------------------------------------------------------------
sub appendTmp {
    my ($key, $value) = @_;

    # Check list of keys that can be added.
    if(!defined ($allowedTmpVals{$key}))
    {
  #      die "ERROR: '$key' cannot be a temporary value\n";
    }
    $tmpVals{$key} .= $value;
}


#--------------------------------------------------------------
#   rmTmp ( key )
# Removes the specified temporary key if it exists.
#--------------------------------------------------------------
sub rmTmp {
    my ($key) = @_;

    delete $tmpVals{$key};
}


#--------------------------------------------------------------
#   getTmp ( key )
# Removes the specified temporary key if it exists.
#--------------------------------------------------------------
sub getTmp {
    my ($key) = @_;
    if(!exists $tmpVals{$key})
    {
        die "TMP Config variable '$key' is not defined\n";
    }

    return($tmpVals{$key});


    #return $returnVal if(defined);
    return "";
}

#--------------------------------------------------------------
#   getStepConf ( step, key[, required] )
# Get the specified conf value.
#--------------------------------------------------------------
sub getStepConf
{
    my ($step, $key, $required) = @_;

    if (! defined($required)) { $required = 0; }

    my $returnVal = getConf("$step/$key", $required);

    return($returnVal);
}


#--------------------------------------------------------------
#   resolveTmp( returnVal )
# Resolve any temporary values in the specified string.
#--------------------------------------------------------------
sub resolveTmp {
    my ($returnVal) = @_;

    if(!defined $returnVal) {die "WHAT????\n";}
    # faster, but doesn't check...    $returnVal =~ s/\?\(([\w\/]+)\)/$tmpVals{$1}/g;
    # TODO - add check for missing tmpVals.

    $returnVal =~ s/\?\(([\w\/]+)\)/$tmpVals{$1}||die "ERROR: $1 found in $returnVal is not set"/ge;
    return($returnVal);
}
#--------------------------------------------------------------
#   subTmp( string, key, value )
# Substitute the value for the key in string.
#--------------------------------------------------------------
sub subTmp
{
    my ($string, $key, $value) = @_;

    $$string =~ s/\?\($key\)/$value/g;
    return($string);
}

#--------------------------------------------------------------
#   getStepInfo ( step, key )
# Currently does not validate that step/key are set.
#--------------------------------------------------------------
sub getStepInfo
{
    my ($step, $key) = @_;
    return($allStepInfo{$step}{$key});
}

#--------------------------------------------------------------
#   unsetStepInfo ( step, key )
# Remove the step info for this key.
#--------------------------------------------------------------
sub unsetStepInfo
{
    my ($step, $key) = @_;
    delete $allStepInfo{$step}{$key};
}

#--------------------------------------------------------------
#   setStepInfo ( step, key, value )
# Set the step info for this key.
#--------------------------------------------------------------
sub setStepInfo
{
    my ($step, $key, $value) = @_;
    $allStepInfo{$step}{$key} = $value;
}

###############################################################
#--------------------------------------------------------------
# Target/Makefile processing
#--------------------------------------------------------------
###############################################################

#--------------------------------------------------------------
#   writeTarget(step)
#
#--------------------------------------------------------------
sub writeTarget {
    my ($output, $depend, $cmd) = @_;

    my $okExt = "OK";

    # Find the directory for the output.
    my ($fileName, $dir) = fileparse($output);

    my $dirDep = "";
    if($dir ne "")
    {
        $dirDep = " | $dir";
        $allDirs{$dir} = undef;
    }

    $cmd =~ s/'/"/g;            # Avoid issues with single quotes in command
    my $newcmd = $opts{runcluster}." ";
    if($opts{batchopts})
    {
        $newcmd .= "-opts '".$opts{batchopts}."' ";
    }
    $newcmd .= "$opts{batchtype} '$cmd'";


    writeMake("$output.$okExt:${depend}${dirDep}");
    writeMake("\n\t$newcmd\n");
    writeMake("\ttouch $output.$okExt\n\n");
}

#--------------------------------------------------------------
#   writeMake(step)
#
#--------------------------------------------------------------
sub writeMake {
    my ($step) = @_;

#    $step =~ s/$outdir/\$(OUT_DIR)/g;
#    $step =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
    print MAK $step;
#    print $step;
}


#--------------------------------------------------------------
#   isBamMakeDepend(step)
# Return 1 if the bam file(s) should be included on the make dependency,
# otherwise, return 0.
#--------------------------------------------------------------
sub isBamMakeDepend {
    my ($step) = @_;

    my $tmpVal = getStepConf($step, "BAM_DEPEND");
    if ((($tmpVal ne '') && ($tmpVal eq "TRUE")) ||
        (($tmpVal eq '') && (getConf("BAM_DEPEND") eq "TRUE")))
    {
        return(1);
    }
    return(0);
}



#--------------------------------------------------------------
#   parseTarget() : Read UCSC BED format as target information
#                   allowing a certain offset from the target
#                   merge overlapping extended intervals if possible
#--------------------------------------------------------------
sub parseTarget {
    my ($bed,$offset) = @_;

    if(!defined $offset || $offset eq "") { $offset = 0; }
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


sub setupStepSettings
{
    my ($step) = @_;

    my $outputType = getStepType($step);
    my $depends = getStepConf($step, "DEPEND", 1);
    my $output = getStepConf($step,"OUTPUT", 1);
    my $cmd = getStepConf($step, "CMD", 1);
    my $bamDepend = isBamMakeDepend($step);
    my $multiOnly = getStepConf($step, "MULTI_ONLY");
    my $singleOnly = getStepConf($step, "SINGLE_ONLY");
    my $inputJoin = getStepConf($step, "INPUT_JOIN");
    my $sampleInfo = getStepConf($step, "SAMPLES");

    # DEPENDS can only contain either BAM or PER_SAMPLE_BAM
    if($depends =~ /\bBAM\b/ && $depends =~ /\bPER_SAMPLE_BAM\b/)
    {
        die "step $step cannot depend on both 'BAM' and 'PER_SAMPLE_BAM'"
    }


    # MULTI_ONLY = PER_SAMPLE_BAM is only valid for OnePerSample
    # and if there is a dependency on BAM
    if(($multiOnly eq "PER_SAMPLE_BAM") &&
       (($outputType ne "OnePerSample") ||
        ($depends !~ /\bBAM\b/)))
    {
        # MULTI_ONLY can only be set to PER_SAMPLE_BAM if its type
        # equals "PerSample".
        die "'MULTI_ONLY' can only be set to 'PER_SAMPLE_BAM' if its type equals 'OnePerSample' and 'DEPEND' contains 'BAM', but type = $outputType & 'DEPEND' = $depends\n";
    }

    # Verify the dependencies are already set & determine the samples to
    # process.
    for my $depend (split(/\s+/, $depends))
    {
        next if(($depend eq "BAM") || ($depend eq "PER_SAMPLE_BAM"));
        if(!exists $allStepInfo{$depend})
        {
            die("$step depends on $depend, but $depend is not prior to $step in the steps\n");
        }

        # Add this step as a child of the dependent step - used for
# cleaning up the dependent step's file list.
#        $allStepInfo{$depend}{CHILDREN}{$step} = undef;
    }
    $allStepInfo{$step}{TYPE} = $outputType;
    @{$allStepInfo{$step}{DEPEND}} = split(/\s+/, $depends);
    $allStepInfo{$step}{OUTPUT} = $output;
    $allStepInfo{$step}{CMD} = $cmd;
    $allStepInfo{$step}{BAM_DEPEND} = $bamDepend;
    $allStepInfo{$step}{MULTI_ONLY} = $multiOnly;
    $allStepInfo{$step}{SINGLE_ONLY} = $singleOnly;
    $allStepInfo{$step}{INPUT_JOIN} = $inputJoin;

    if($sampleInfo ne "")
    {
        if($sampleInfo eq "MULTI_BAM")
        {
            $allStepInfo{$step}{SAMPLES} = \%multiBamSamples;
            $allStepInfo{$step}{SAMPLES_ARRAY} = \@multiBamSamplesArray;
        }
        elsif($sampleInfo eq "SINGLE_BAM")
        {
            $allStepInfo{$step}{SAMPLES} = \%singleBamSamples;
            $allStepInfo{$step}{SAMPLES_ARRAY} = \@singleBamSamplesArray;
        }
        else
        {
            die "ERROR: '$step/SAMPLES' set to unknown value '$sampleInfo'.  Only 'MULTI_BAM' and 'SINGLE_BAM' are supported.\n";
        }
    }
    else
    {
        # Pull from dependencies - TODO - for now just set to all.
        $allStepInfo{$step}{SAMPLES} = \%samples;
        $allStepInfo{$step}{SAMPLES_ARRAY} = \@samplesArray;
    }

    # if we are generating a file containing the outputs, remove it if it already exists.
    if(getStepConf($step, "FILELIST"))
    {
        my $filelistName = getStepConf($step, "FILELIST");
        if(-e $filelistName)
        {
            unlink $filelistName or die "Failed to remove previous $filelistName\n";
        }
    }
}
