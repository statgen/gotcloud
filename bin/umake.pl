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
use warnings;
use Cwd;
use Getopt::Long;
use File::Path qw(make_path);
use File::Basename;
use Cwd 'abs_path';

# Set the umake base directory.
$_ = abs_path($0);
my($scriptName, $scriptPath) = fileparse($_);
my $scriptDir = abs_path($scriptPath);
my $gotcloudRoot = $scriptDir;
if ($scriptDir =~ /(.*)\/bin/) { $gotcloudRoot = $1;}
push @INC,$scriptPath;                  # Use lib is a BEGIN block and does not work

#############################################################################
## STEP 1 : Load configuration file
############################################################################
my $help = "";
my $testdir = "";
my $outdir = "";
my $conf = "";
my $numjobs = 0;
my $maxlocaljobs = 10;
my $snpcallOpt = "";
my $extractOpt = "";
my $beagleOpt = "";
my $thunderOpt = "";
my $indexOpt = "";
my $pileupOpt = "";
my $glfMultiplesOpt = "";
my $vcfPileupOpt = "";
my $filterOpt = "";
my $svmOpt = "";
my $splitOpt = "";
my $makebasename = "";
#my $override = "";
#my $localdefaults = "";
my $callregion = "";
my $verbose = "";
my $copyglf = "";
my $chroms = "";

my $baseprefix = '';
my $bamprefix = '';
my $refprefix = '';
#my $vcfdir = '';

my $batchtype = '';
my $batchopts = '';
my $gcroot = '';
my $noPhoneHome = '';

my $optResult = GetOptions("help",\$help,
                           "test=s",\$testdir,
                           "outdir|out_dir=s",\$outdir,
                           "conf=s",\$conf,
                           "numjobs=i",\$numjobs,
                           "maxlocaljobs=i",\$maxlocaljobs,
                           "snpcall",\$snpcallOpt,
                           "extract",\$extractOpt,
                           "beagle",\$beagleOpt,
                           "thunder",\$thunderOpt,
                           "index",\$indexOpt,
                           "pileup",\$pileupOpt,
                           "glfMultiples",\$glfMultiplesOpt,
                           "vcfPileup",\$vcfPileupOpt,
                           "filter",\$filterOpt,
                           "svm",\$svmOpt,
                           "split",\$splitOpt,
                           "makebasename|make_basename|make_base_name=s",\$makebasename,
#                           "override=s",\$override,
                           "region=s",\$callregion,
                           "batchtype|batch_type=s",\$batchtype,
                           "batchopts|batch_opts=s",\$batchopts,
                           "baseprefix|base_prefix=s",\$baseprefix,
                           "bamprefix|bam_prefix=s",\$bamprefix,
                           "refprefix|ref_prefix=s",\$refprefix,
#                           "vcfdir|vcf_dir=s",\$vcfdir,
#                           "localdefaults=s",\$localdefaults,
                           "verbose", \$verbose,
                           "copyglf=s", \$copyglf,
                           "chrs|chroms=s", \$chroms,
                           "gotcloudroot|gcroot=s", \$gcroot,
                           "noPhoneHome", \$noPhoneHome
    );

my $usage = "Usage:\tgotcloud snpcall --conf [conf.file]\n".
"\tgotcloud ldrefine --conf [conf.file]\n".
"\tgotcloud vc --conf [conf.file]\n".
"Specify --help to get more usage infromation";
die "Error in parsing options\n$usage\n" unless ( ($optResult) && (($conf) || ($help) || ($testdir)) );

# check if help.
if ($help) {
    system("perldoc $0");
    exit 1;
}

# Check the conf file for GOTCLOUD_ROOT
my @configs = split(' ', $conf);
if(!$gcroot)
{
    foreach my $file (@configs)
    {
        my $fileContents;
        open my $openFile, '<', $file or die $!;
        $fileContents = <$openFile>;
        close $openFile;

        if ($fileContents =~ m/^\s*GOTCLOUD_ROOT\s*=\s*(.*)/)
        {
            $gcroot = "$1";
            last;
        }
    }
}

if($gcroot)
{
    $gotcloudRoot = $gcroot;
    $scriptPath = "$gotcloudRoot/bin/";
    push @INC,$scriptPath;
}

#############################################################################
#   Global Variables
############################################################################
my @confSettings;
push(@confSettings, "GOTCLOUD_ROOT = $gotcloudRoot");

require GC_Common;
require Conf;
#require Multi;

my %opts = (
    phonehome => "$gotcloudRoot/scripts/gcphonehome.pl -pgmname GotCloud $scriptName",
    pipelinedefaults => $scriptPath . '/gotcloudDefaults.conf',
);
my $runcluster = "\$(GOTCLOUD_ROOT)/scripts/runcluster.pl";

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
    $testdir = $gotcloudRoot . '/test/umake';
    # First check that the test directory exists.
    if(! -r $testdir)
    {
        die "ERROR, '$testdir' does not exist, please download the test data to that directory\n";
    }
    my $cmd = "$0 --conf $testdir/umake_test.conf --snpcall ";
    if($gcroot)
    {
        $cmd .= "--gotcloudRoot $gcroot ";
    }
    $cmd .= "--outdir $testoutdir --numjobs 2 1> $testoutdir.log 2>&1";
    system($cmd) &&
        die "Failed to generate test data. Not a good thing.\nCMD=$cmd\n";
    $cmd = "$gotcloudRoot/scripts/diff_results_umake.sh $outdir $gotcloudRoot/test/umake/expected";
    system($cmd) &&
        die "Comparison failed, test case FAILED.\nCMD=$cmd\n";
    print "Successfully ran the test case, congratulations!\n";
    exit;
}

#--------------------------------------------------------------
#   Convert command line options to conf settings
#--------------------------------------------------------------
#   Set the configuration values for applicable command-line options.
if ($bamprefix)  { push(@confSettings, "BAM_PREFIX = $bamprefix"); }
if ($refprefix)  { push(@confSettings, "REF_PREFIX = $refprefix"); }
if ($baseprefix) { push(@confSettings, "BASE_PREFIX = $baseprefix"); }
if ($makebasename)   { push(@confSettings, "MAKE_BASE_NAME = $makebasename"); }
if ($outdir)     { push(@confSettings, "OUT_DIR = $outdir"); }
if ($copyglf)    { push(@confSettings, "COPY_GLF = $copyglf"); }
if ($chroms)     { $chroms =~ s/,/ /g; push(@confSettings, "CHRS = $chroms"); }

#--------------------------------------------------------------
#   Load configuration settings
#--------------------------------------------------------------
push(@configs, $opts{pipelinedefaults});

if (loadConf(\@confSettings, \@configs, $verbose)) {
    die "Failed to read configuration files\n";
}

#--------------------------------------------------------------
#   Set variables from configuration settings
#--------------------------------------------------------------
$copyglf = getConf("COPY_GLF");


#-------------
# Handle cluster setup.
# Pull batch info from config if not on command line.
if ( $batchopts eq "" ) {
    $batchopts = getConf("BATCH_OPTS");
}
if ( $batchtype eq "" ) {
    $batchtype = getConf("BATCH_TYPE");
}
if ($batchtype eq "")
{
    $batchtype = "local";
    setConf("BATCH_TYPE", "local");
}

if ($batchtype eq 'flux') { $batchtype = 'pbs'; }

#   All set now, phone home to check for a new version. We don't care about failures.
if(!$noPhoneHome)
{
    system($opts{phonehome});
}
else
{
    setConf("BAMUTIL_THINNING", "--phoneHomeThinning 0");
}

#### POSSIBLE FLOWS ARE
## SNPcall : PILEUP -> GLFMULTIPLES -> VCFPILEUP -> FILTER -> SVM -> SPLIT : 1,2,3,4,5,7
## Extract : PILEUP -> GLFEXTRACT -> SPLIT : 1,6,7
## BEAGLE  : BEAGLE -> SUBSET : 8,9
## THUNDER : THUNDER -> 10
my @orders = qw(RUN_INDEX RUN_PILEUP RUN_GLFMULTIPLES RUN_VCFPILEUP RUN_FILTER RUN_SVM RUN_EXTRACT RUN_SPLIT RUN_BEAGLE RUN_SUBSET RUN_THUNDER);
my @orderFlags = ();

## if --snpcall --beagle --subset or --thunder
if ( ( $snpcallOpt) || ( $beagleOpt ) || ( $thunderOpt ) || ( $extractOpt ) ||
     ($indexOpt) || ($pileupOpt) || ($glfMultiplesOpt) || ($vcfPileupOpt) ||
     ($filterOpt) || ($svmOpt) || ($splitOpt) ) {
    foreach my $o (@orders) {
        push(@orderFlags, 0);
        setConf($o, "FALSE");
    }
    if ( $snpcallOpt ) {
        foreach my $i (1,2,3,4,5,7) { # PILEUP to SPLIT
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $extractOpt ) {
        foreach my $i (1,6,7) { # PILEUP, EXTRACT, SPLIT
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $beagleOpt ) {
        foreach my $i (8,9) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $thunderOpt ) {
        foreach my $i (10) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $indexOpt ) {
        foreach my $i (0) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $pileupOpt ) {
        foreach my $i (1) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $glfMultiplesOpt ) {
        foreach my $i (2) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $vcfPileupOpt ) {
        foreach my $i (3) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $filterOpt ) {
        foreach my $i (4) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $svmOpt ) {
        foreach my $i (5) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $splitOpt ) {
        foreach my $i (7) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
}
else {
    foreach my $o (@orders) {
        push(@orderFlags, ( getConf($o) eq "TRUE") ? 1 : 0 );
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

print STDERR "Key configurations:\n";
print STDERR "GOTCLOUD_ROOT: ".getConf("GOTCLOUD_ROOT")."\n";
print STDERR "OUT_DIR:       ".getConf("OUT_DIR")."\n";
print STDERR "BAM_INDEX:     ".getConf("BAM_INDEX")."\n";
print STDERR "REF:           ".getConf("REF")."\n";
print STDERR "CHRS:          ".getConf("CHRS")."\n";
print STDERR "BATCH_TYPE:    $batchtype\n";
print STDERR "BATCH_OPTS:    $batchopts\n";
print STDERR "\n";
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

#--------------------------------------------------------------
#   Check required settings
#--------------------------------------------------------------
my $failReqFile = "0";
# Check to see if the old REF is set instead of the new one.
if( getConf("FA_REF") )
{
    warn "ERROR: FA_REF is deprecated and has been replaced by REF, please update your configuration file and rerun\n";
    $failReqFile = "1";
}

if( getConf("DBSNP_PREFIX") )
{
    warn "ERROR: DBSNP_PREFIX is deprecated and has been replaced by DBSNP_VCF, please update your configuration file and rerun\n";
    $failReqFile = "1";
}

if( getConf("HM3_PREFIX") )
{
    warn "ERROR: HM3_PREFIX is deprecated and has been replaced by HM3_VCF, please update your configuration file and rerun\n";
    $failReqFile = "1";
}

if( getConf("OUTPUT_DIR") )
{
    warn "ERROR: OUTPUT_DIR is deprecated and has been replaced by OUT_DIR, please update your configuration file and rerun\n";
    $failReqFile = "1";
}

if( getConf("OUT_PREFIX") )
{
    warn "ERROR: OUT_PREFIX is deprecated and has been replaced by MAKE_BASE_NAME, please update your configuration file and rerun\n";
    $failReqFile = "1";
}

if($failReqFile eq "1")
{
    die "Exiting pipeline due to deprecated settings, please fix & rerun\n";
}

# convert the reference to absolute path.
my $newpath = getAbsPath(getConf("REF"), "REF");
setConf("REF", $newpath);
# Verify the REF file is readable.
if(! -r getConf("REF") )
{
    warn "ERROR: Could not read required REF: ".getConf("REF")."\n";
    $failReqFile = "1";
}

# RUN_SVM & RUN_FILTER need dbsnp & HM3 files
if( (getConf("RUN_SVM") eq "TRUE") ||
    (getConf("RUN_FILTER") eq "TRUE") )
{
    # convert dbsnp & HM3 to absolute paths
    $newpath = getAbsPath(getConf("DBSNP_VCF"), "REF");
    setConf("DBSNP_VCF", $newpath);
    $newpath = getAbsPath(getConf("HM3_VCF"), "REF");
    setConf("HM3_VCF", $newpath);

    # Verify the DBSNP file is readable.
    if(! -r getConf("DBSNP_VCF") )
    {
        warn "ERROR: Could not read required DBSNP_VCF: ".getConf("DBSNP_VCF")."\n";
        $failReqFile = "1";
    }
    if(! -r getConf("DBSNP_VCF").".tbi")
    {
        warn "ERROR: Could not read required DBSNP_VCF.tbi: ".getConf("DBSNP_VCF").".tbi\n";
        $failReqFile = "1";
    }

    if(! -r getConf("HM3_VCF"))
    {
        warn "ERROR: Could not read required HM3_VCF: ".getConf("HM3_VCF")."\n";
        $failReqFile = "1";
    }
    if(! -r getConf("HM3_VCF").".tbi")
    {
        warn "ERROR: Could not read required HM3_VCF.tbi: ".getConf("HM3_VCF").".tbi\n";
        $failReqFile = "1";
    }
}

if(!getConf("BAM_INDEX"))
{
    warn "ERROR: 'BAM_INDEX' required, but not set.\n";
    $failReqFile = "1";
}

if(getConf("RUN_SVM") eq "TRUE")
{
    # Convert OMNI to absolute path.
    $newpath = getAbsPath(getConf("OMNI_VCF"), "REF");
    setConf("OMNI_VCF", $newpath);
    if(! -r getConf("OMNI_VCF"))
    {
        warn "ERROR: Could not read required OMNI_VCF: ".getConf("OMNI_VCF")."\n";
        $failReqFile = "1";
    }
}

my @chrs = split(/\s+/,getConf("CHRS"));
if ( getConf("RUN_FILTER") eq "TRUE" )
{
    # convert the INDEL_PREFIX to an absolute path.
    $newpath = getAbsPath(getConf("INDEL_PREFIX"), "REF");
    setConf("INDEL_PREFIX", $newpath);
    # check for the INDEL files for each chromosome
    foreach my $chr (@chrs)
    {
        if(! -r getConf("INDEL_PREFIX").".chr$chr.vcf")
        {
            warn "ERROR: Could not read required indel file based on INDEL_PREFIX for chr $chr: ".getConf("INDEL_PREFIX").".chr$chr.vcf\n";
            $failReqFile = "1";
        }
    }
}

if($failReqFile eq "1")
{
    die "Exiting pipeline due to required file(s) missing\n";
}

#----------------------------------------------------------------------------
#   Check for required executables
#----------------------------------------------------------------------------
my @reqExes;

# required executables for each step.
my %reqExeHash = (
                  'RUN_INDEX' => [qw(SAMTOOLS_FOR_OTHERS)],
                  'RUN_PILEUP' => [qw(GLFMERGE SAMTOOLS_FOR_OTHERS SAMTOOLS_FOR_PILEUP BAMUTIL)],
                  'RUN_GLFMULTIPLES' => [qw(GLFMULTIPLES VCFMERGE)],
                  'RUN_FILTER' => [qw(INFOCOLLECTOR VCFCOOKER VCFPASTE BGZIP TABIX VCFSUMMARY VCFMERGE)],
                  'RUN_VCFPILEUP' => [qw(VCFPILEUP)],
                  'RUN_SVM' => [qw(VCFPASTE BGZIP TABIX VCFSUMMARY SVM_SCRIPT SVMLEARN SVMCLASSIFY INVNORM VCF_SPLIT_CHROM)],
                  'RUN_EXTRACT' => [qw(BGZIP TABIX GLFEXTRACT)],
                  'RUN_SPLIT' => [qw(BGZIP VCFSPLIT)],
                  'RUN_BEAGLE'=> [qw(LIGATEVCF BGZIP TABIX VCF2BEAGLE BEAGLE BEAGLE2VCF)],
                  'RUN_SUBSET' => [qw(VCFCOOKER TABIX VCFSPLIT)],
                  'RUN_THUNDER' => [qw(LIGATEVCF BGZIP TABIX THUNDER)],
                 );

my $missingExe = 0;
foreach my $step (keys %reqExeHash)
{
    if(! getConf($step)) { next; } # skip if this step is not beign run
    # check for each exe required by this step.
    foreach my $exe (@{$reqExeHash{$step}})
    {
        my ($prog, $second, $rest) = split(/ /, getConf($exe));
        if($prog eq 'perl')
        {
            if(-r $second) { next; }
            print "$exe, $prog is not executable\n";
            $missingExe++;
        }
        elsif($prog ne 'java')
        {
            if(-x $prog) { next; }
            print "$exe, $prog is not executable\n";
            $missingExe++;
        }
    }
}

if($missingExe)
{
    die "EXITING: Missing required exes.  Try typing 'make' in the gotcloud/src directory\n";
}

#----------------------------------------------------------------------------
#   Output the configuration settings.
#----------------------------------------------------------------------------
my $makeext = "vc";
if($snpcallOpt)
{
    $makeext = "snpcall";
}
elsif($extractOpt)
{
    $makeext = "extract";
}
elsif($beagleOpt)
{
    $makeext = "beagle";
}
elsif($thunderOpt)
{
    $makeext = "thunder";
}

$outdir = getConf("OUT_DIR");
unless ( $outdir =~ /^\// ) {
    $outdir = getcwd()."/".$outdir;
    setConf('OUT_DIR', $outdir);
}

system("mkdir -p $outdir") &&
die "Unable to create directory '$outdir'\n";
dumpConf("$outdir/".getConf("MAKE_BASE_NAME").".$makeext.conf");


#############################################################################
## STEP 2 : Parse BAM INDEX FILE
############################################################################
my $bamIndex = getAbsPath(getConf("BAM_INDEX"));
my $pedIndex = getConf("PED_INDEX");
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
                my $val = getConf($key);
                $bam =~ s/\$\($key\)/$val/;
            }
            # Check if there is just a relative path to the bams.
            if ( !( $bam =~ /^\// ) )
            {
                # It is relative, so make it absolute.
                $bam = getAbsPath($bam, "BAM");
            }
        }
        push(@allbamSMs,$smID);

        # If a step that requires the BAMs is beign used, check
        # that the BAMs can be read.
        if ( (getConf("RUN_INDEX") eq "TRUE") ||
             (getConf("RUN_PILEUP") eq "TRUE") ||
             (getConf("RUN_VCFPILEUP") eq "TRUE") )
        {
            # die if bam is not readable
            unless ( -r $bam ) { die "ERROR: Cannot read '$bam'\n"; }
            unless ( -s $bam ) { die "ERROR: $bam' is empty.\n"; }
        }
    }
    push(@allSMs,$smID);
    push(@allbams,@bams);
}

close IN;

$numSamples = @allSMs;

if ( $pedIndex ne "" ) {
    # Convert to absolute path.
    $pedIndex = getAbsPath($pedIndex);
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

#############################################################################
## STEP 3 : Create MAKEFILE
############################################################################

my $makef = getConf("OUT_DIR")."/".getConf("MAKE_BASE_NAME").".$makeext.Makefile";
my @nobaqSubstrings = split(/\s+/,getConf("NOBAQ_SUBSTRINGS"));

open(MAK,">$makef") || die "Cannot open $makef for writing\n";
print MAK "OUT_DIR=$outdir\n";
print MAK "GOTCLOUD_ROOT=$gotcloudRoot\n\n";
print MAK ".DELETE_ON_ERROR:\n\n";

print MAK "all:";
foreach my $chr (@chrs) {
    print MAK " all$chr";
}
print MAK "\n\n";


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
my $unitChunk = getConf("UNIT_CHUNK");
my $bamGlfDir = "\$(OUT_DIR)/".getConf("BAM_GLF_DIR");
my $smGlfDir = "\$(OUT_DIR)/".getConf("SM_GLF_DIR");
my $smGlfDirReal = "$outdir/".getConf("SM_GLF_DIR");
my $vcfDir = "\$(OUT_DIR)/".getConf("VCF_DIR");
my $pvcfDir = "\$(OUT_DIR)/".getConf("PVCF_DIR");
my $splitDir = "\$(OUT_DIR)/".getConf("SPLIT_DIR");
my $splitDirReal = "$outdir/".getConf("SPLIT_DIR");
my $targetDir = "\$(OUT_DIR)/".getConf("TARGET_DIR");
my $targetDirReal = "$outdir/".getConf("TARGET_DIR");
my $beagleDir = "\$(OUT_DIR)/".getConf("BEAGLE_DIR");
my $thunderDir = "\$(OUT_DIR)/".getConf("THUNDER_DIR");
my $thunderDirReal = "$outdir/".getConf("THUNDER_DIR");
my $remotePrefix = getConf("REMOTE_PREFIX");

my $bamIndexRemote = ($bamIndex =~ /^\//) ? "$remotePrefix$bamIndex" : ($remotePrefix.getcwd()."/".$bamIndex);

my $sleepMultiplier = getConf("SLEEP_MULT");
if($sleepMultiplier eq "")
{
    $sleepMultiplier = 0;
}

my @wgsFilterDepSites;
my $wgsFilterDepVcfs= "";

# Use a filter prefix for hard filtering if running SVM
my $filterPrefix = "";
if ( getConf("RUN_SVM") eq "TRUE") {
    $filterPrefix = "hard";
}

#############################################################################
## STEP 6 : PARSE TARGET INFORMATION
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
    my $r = parseTarget($bed,getConf("OFFSET_OFF_TARGET"));
    push(@targetIntervals,$r);
}

#############################################################################
## ITERATE EACH CHROMOSOME
############################################################################
foreach my $chr (@chrs) {
    print STDERR "Generating commands for chr$chr...\n";
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
    if ( ( ( getConf("WRITE_TARGET_LOCI") eq "TRUE" ) ||
           ( getConf("WRITE_TARGET_LOCI") eq "ALWAYS" ) ) &&
         ( getConf("RUN_PILEUP") eq "TRUE" ) )
    {
        die "No target file is given but WRITE_TARGET_LOCI is TRUE\n" if ( $#uniqBeds < 0 );

        ## Generate target loci information
        for(my $i=0; $i < @uniqBeds; ++$i) {
            my $printBedName = 0;
            my $outDir = "$targetDirReal/$uniqBedFns[$i]/chr$chr";
            make_path($outDir);
            for(my $j=0; $j < @unitStarts; ++$j) {
                if( ( getConf("WRITE_TARGET_LOCI") eq "ALWAYS" ) ||
                    (! -r "$outDir/$chr.$unitStarts[$j].$unitEnds[$j].loci") ||
                    ( -M "$uniqBeds[$i]" < -M "$outDir/$chr.$unitStarts[$j].$unitEnds[$j].loci" ) )
                {
                    if($printBedName == 0)
                    {
                        print STDERR "Writing target loci for $uniqBeds[$i]...\n";
                        $printBedName = 1;
                    }

                    print STDERR "Writing loci for $chr:$unitStarts[$j]-$unitEnds[$j]...\n";
                    open(LOCI,">$outDir/$chr.$unitStarts[$j].$unitEnds[$j].loci") || die "Cannot create $outDir/$chr.loci\n";
                    foreach my $p (@{$targetIntervals[$i]->{$chr}})
                    {
                        my $start = ( $p->[0] < $unitStarts[$j] ) ? $unitStarts[$j] : $p->[0];
                        my $end = ( $p->[1] < $unitEnds[$j] ) ? $p->[1] : $unitEnds[$j];
                        #die "@{$p} $start $end\n";
                        for(my $k=$start; $k <= $end; ++$k)
                        {
                            print LOCI "$chr\t$k\n";
                        }
                    }
                    close LOCI;
                }
            }
        }
    }

    #############################################################################
    ## STEP 10 : MAIN PART TO WRITE MAKEFILE
    #############################################################################
    print MAK "all$chr:";
    print MAK " thunder$chr" if ( getConf("RUN_THUNDER") eq "TRUE" );
    print MAK " subset$chr" if ( getConf("RUN_SUBSET") eq "TRUE" );
    print MAK " beagle$chr" if ( getConf("RUN_BEAGLE") eq "TRUE" );
    print MAK " split$chr" if ( getConf("RUN_SPLIT") eq "TRUE" );
    print MAK " filt$chr" if ( getConf("RUN_EXTRACT") eq "TRUE" );
    print MAK " svm$chr" if ( getConf("RUN_SVM") eq "TRUE" );
    print MAK " filt$chr" if ( getConf("RUN_FILTER") eq "TRUE" );
    print MAK " pvcf$chr" if ( getConf("RUN_VCFPILEUP") eq "TRUE" );
    print MAK " vcf$chr" if ( getConf("RUN_GLFMULTIPLES") eq "TRUE" );
    print MAK " glf$chr" if ( getConf("RUN_PILEUP") eq "TRUE" );
    print MAK " bai" if ( getConf("RUN_INDEX") eq "TRUE" );
    print MAK "\n\n";

    #############################################################################
    ## STEP 10-9 : RUN MaCH GENOTYPE REFINEMENT
    #############################################################################
    if ( getConf("RUN_THUNDER") eq "TRUE" ) {
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
            my $cmd = getConf("LIGATEVCF")." ".join(".vcf.gz ",@thunderOuts).".vcf.gz 2> $thunderPrefix.vcf.gz.err | ".getConf("BGZIP")." -c > $thunderPrefix.vcf.gz";
            writeLocalCmd($cmd);
            $cmd = getConf("TABIX")." -f -pvcf $thunderPrefix.vcf.gz";
            writeLocalCmd($cmd);

            for(my $i=0; $i < $nsplits; ++$i) {
                my $j = $i+1;
                my $thunderOut = "$thunderOutPrefix.$j";
                print MAK "$thunderOut.vcf.gz.OK:\n";
                print MAK "\tmkdir --p $thunderDir/chr$chr/$pop/thunder\n";
                my $cmd = getConf("THUNDER")." --shotgun $splitVcfs[$i] -o $remotePrefix$thunderOut > $remotePrefix$thunderOut.out 2> $remotePrefix$thunderOut.err";
                $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                print MAK "\t".getMosixCmd($cmd)."\n";
                $cmd = "touch $thunderOut.vcf.gz.OK";
                print MAK "\t$cmd\n";
                print MAK "\n";
            }
        }
    }

    #############################################################################
    ## STEP 10-8 : SUBSET INTO POPULATION GROUPS FOR THUNDER REFINEMENT
    #############################################################################
    if ( getConf("RUN_SUBSET") eq "TRUE" ) {
        my $expandFlag = ( getConf("RUN_BEAGLE") eq "TRUE" ) ? 1 : 0;

        print MAK "subset$chr:";
        foreach my $pop (@pops) {
            print MAK " $thunderDir/chr$chr/$pop/split/chr$chr.filtered.PASS.beagled.$pop.split.vcflist";
        }
        print MAK "\n\n";

        my $nLdSNPs = getConf("LD_NSNPS");
        my $nLdOverlap = getConf("LD_OVERLAP");
        my $mvcf = "$remotePrefix$vcfDir/chr$chr/chr$chr.filtered.vcf.gz";

        if ( $expandFlag == 1 ) {
            print MAK "$beagleDir/chr$chr/subset.OK: beagle$chr\n";
        }
        else {
            print MAK "$beagleDir/chr$chr/subset.OK:\n";
        }
        my $beaglePrefix = "$beagleDir/chr$chr/chr$chr.filtered.PASS.beagled";
        if ( $#pops > 0 ) {
            my $cmd = getConf("VCFCOOKER")." --in-vcf $remotePrefix$beaglePrefix.vcf.gz --out $remotePrefix$beaglePrefix --subset --in-subset $bamIndexRemote --bgzf 2> $remotePrefix$beaglePrefix.subset.err";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd)."\n";
            print MAK "\n";
            foreach my $pop (@pops) {
                $cmd = "\t".getConf("TABIX")." -f -pvcf $remotePrefix$beaglePrefix.$pop.vcf.gz\n";
                $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
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
            my $cmd = getConf("VCFSPLIT")." --in $remotePrefix$beaglePrefix.$pop.vcf.gz --out $remotePrefix$splitPrefix --nunit $nLdSNPs --noverlap $nLdOverlap 2> $remotePrefix$splitPrefix.err";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd)."\n\n";
        }
    }

    #############################################################################
    ## STEP 10-7 : RUN BEAGLE GENOTYPE REFINEMENT
    #############################################################################
    if ( getConf("RUN_BEAGLE") eq "TRUE" ) {
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
        my $cmd = getConf("LIGATEVCF")." ".join(".vcf.gz ",@beagleOuts).".vcf.gz 2> $beaglePrefix.vcf.gz.err | ".getConf("BGZIP")." -c > $beaglePrefix.vcf.gz";
        writeLocalCmd($cmd);
        $cmd = getConf("TABIX")." -f -pvcf $beaglePrefix.vcf.gz";
        writeLocalCmd($cmd);
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
            my $cmd = getConf("VCF2BEAGLE")." --in $splitVcfs[$i] --out $remotePrefix$beagleLikeDir/chr$chr.PASS.$j.gz";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd)."\n";
            $cmd = getConf("BEAGLE")." like=$remotePrefix$beagleLikeDir/chr$chr.PASS.".($i+1).".gz out=$remotePrefix$beagleOutPrefix.$j >$remotePrefix$beagleOutPrefix.$j.out 2>$remotePrefix$beagleOutPrefix.$j.err";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd)."\n";
            $cmd = getConf("BEAGLE2VCF"). " --filter --beagle $remotePrefix$beagleOut.gz --invcf $splitVcfs[$i] --outvcf $remotePrefix$beagleOut.vcf";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd)."\n";
            $cmd = getConf("BGZIP"). " -f $remotePrefix$beagleOut.vcf";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd)."\n";
            $cmd = getConf("TABIX"). " -f -pvcf $remotePrefix$beagleOut.vcf.gz";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd)."\n";
            print MAK "\n";
        }
    }

    #############################################################################
    ## STEP 10-6 : SPLIT FILTERED VCF INTO CHUNKS FOR GENOTYPING
    #############################################################################
    if ( getConf("RUN_SPLIT") eq "TRUE" ) {
        # determine whether to expand to lower level target or not
        my $expandFlag = ( getConf("RUN_FILTER") eq "TRUE" ) ? 1 : 0;
        $expandFlag = 1 if ( getConf("RUN_EXTRACT") eq "TRUE" );
        $expandFlag = 2 if ( getConf("RUN_SVM") eq "TRUE" );

        print MAK "split$chr:";
        my $splitPrefix = "$splitDir/chr$chr/chr$chr.filtered.PASS.split";
        print MAK " $splitPrefix.vcflist";
        print MAK "\n\n";

        my $nLdSNPs = getConf("LD_NSNPS");
        my $nLdOverlap = getConf("LD_OVERLAP");
        my $mvcf = "$remotePrefix$vcfDir/chr$chr/chr$chr.filtered.vcf.gz";

        my $subsetPrefix = "$splitDir/chr$chr/chr$chr.filtered";
        if ( $expandFlag == 1 ) {
            print MAK "$splitDir/chr$chr/subset.OK: filt$chr\n";
        }
        elsif ( $expandFlag == 2 ) {
            print MAK "$splitDir/chr$chr/subset.OK: $remotePrefix$vcfDir/chr$chr/chr$chr.filtered.vcf.gz.OK\n";
        }
        else {
            print MAK "$splitDir/chr$chr/subset.OK:\n";
        }
        print MAK "\tmkdir --p $splitDir/chr$chr\n";
        my $cmd = "zcat $mvcf | grep -E \\\"\\sPASS\\s|^#\\\" | ".getConf("BGZIP")." -c > $subsetPrefix.PASS.vcf.gz";
        writeLocalCmd($cmd);
        print MAK "\ttouch $splitDir/chr$chr/subset.OK\n\n";

        print MAK "$splitPrefix.vcflist: $splitDir/chr$chr/subset.OK\n";
        print MAK "\tmkdir --p $splitDir/chr$chr\n";
        $cmd = getConf("VCFSPLIT")." --in $remotePrefix$subsetPrefix.PASS.vcf.gz --out $remotePrefix$splitPrefix --nunit $nLdSNPs --noverlap $nLdOverlap 2> $remotePrefix$splitPrefix.err";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "\t".getMosixCmd($cmd)."\n\n";
    }

    #############################################################################
    ## STEP 10-6b : SPLIT FILTERED VCF INTO CHUNKS FOR GENOTYPING
    #############################################################################
    if ( getConf("RUN_EXTRACT") eq "TRUE" ) {
        my $expandFlag = ( getConf("RUN_PILEUP") eq "TRUE" ) ? 1 : 0;
        my $vcfParent = "$remotePrefix$vcfDir/chr$chr";
        my $vcf = "$vcfParent/chr$chr.filtered.vcf";
        my @vcfs = ();
        my @svcfs = ();
        for(my $j=0; $j < @unitStarts; ++$j) {
            $vcfParent = "$remotePrefix$vcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
            push(@vcfs,"$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].vcf");
            push(@svcfs,"$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].sites.vcf");
        }

        my $invcf = getConf("VCF_EXTRACT");
        unless ( ( $invcf =~ /.gz$/ ) && ( -s $invcf ) && ( -s "$invcf.tbi" ) ) {
            die "Input VCF file $invcf must be bgzipped and tabixed\n";
        }

        print MAK "filt$chr: $vcf.OK".(($expandFlag == 1) ? " glf$chr" : "")."\n\n";
        print MAK "$vcf.OK: ";
        print MAK join(".OK ",@vcfs);
        print MAK ".OK\n";
        my $cmd = getConf("VCFCAT")." @vcfs  | ".getConf("BGZIP")." -c > $vcf.gz";
        writeLocalCmd($cmd);
        print MAK "\ttouch $vcf.OK\n\n";

        for(my $j=0; $j < @unitStarts; ++$j) {
            $vcfParent = "$remotePrefix$vcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
            print MAK "$svcfs[$j].OK:\n";
            print MAK "\tmkdir --p $vcfParent\n";
            $cmd = getConf("TABIX")." $invcf $chr:$unitStarts[$j]-$unitEnds[$j] | cut -f 1-8 > $svcfs[$j]";
            writeLocalCmd($cmd);
            print MAK "\ttouch $svcfs[$j].OK\n\n";

            my @glfs = ();
            my $smGlfBase = "chr$chr/$unitStarts[$j].$unitEnds[$j]";
            my $smGlfParent = "$remotePrefix$smGlfDirReal/$smGlfBase";
            my $smGlfParentCopy = ( $copyglf ? "$copyglf/$smGlfBase" : $smGlfParent );
            for(my $i=0; $i < @allSMs; ++$i) {
                my $smGlfFn = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
                my $smGlf = "$smGlfParent/$smGlfFn";
                push(@glfs,$smGlf);
            }

            handleGlfIndexFile($smGlfParentCopy, $smGlfParent, $chr,
                               $unitStarts[$j], $unitEnds[$j]);

            my $glfAlias = "$smGlfParent/".getConf("GLF_INDEX");
            $glfAlias =~ s/$outdir/\$(OUT_DIR)/g;

            my $sleepSecs = ($j % 10)*$sleepMultiplier;
            $cmd = getConf("GLFEXTRACT")." --invcf $svcfs[$j] --ped $glfAlias -b $vcfs[$j] > $vcfs[$j].log 2> $vcfs[$j].err";
            if ( $copyglf ) {
                $cmd = "mkdir --p $copyglf/chr$chr && rsync -arv $smGlfParent $copyglf/chr$chr && $cmd && rm -rf $smGlfParentCopy";
            }
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$vcfs[$j].OK: $svcfs[$j].OK ";
            if ( $expandFlag == 1 ) {
                print MAK join(".OK ",@glfs);
                print MAK ".OK";
            }
            print MAK "\n";
            #       print MAK "\tmkdir --p $vcfParent\n";
            if($sleepSecs != 0)
            {
                print MAK "\tsleep $sleepSecs\n";
            }
            print MAK "\t".getMosixCmd($cmd)."\n";
            print MAK "\ttouch $vcfs[$j].OK\n\n";
        }
    }

    #############################################################################
    ## STEP 10.5 : RUN SVM FILTERING
    #############################################################################
    if ( getConf("RUN_SVM") eq "TRUE") {
        my $vcfParent = "$remotePrefix$vcfDir/chr$chr";
        my $svcf = "$vcfParent/chr$chr.${filterPrefix}filtered.sites.vcf";
        my $vcf = "$vcfParent/chr$chr.merged.vcf";

        my $expandFlag = ( getConf("RUN_FILTER") eq "TRUE" ) ? 1 : 0;

        my @cmds = ();

        my $mvcfPrefix = "$remotePrefix$vcfDir/chr$chr/chr$chr";

        print MAK "svm$chr: $mvcfPrefix.filtered.vcf.gz.OK\n\n";

        my $cmd = "";

        if ( getConf("WGS_SVM") eq "TRUE")
        {
            print MAK "$mvcfPrefix.filtered.vcf.gz.OK: $remotePrefix$vcfDir/filtered.vcf.gz.OK\n";
            push(@wgsFilterDepSites, "$mvcfPrefix.${filterPrefix}filtered.sites.vcf");
            $wgsFilterDepVcfs .= " $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK";
        }
        else
        {
            if ( $expandFlag == 1 ) {
                print MAK "$mvcfPrefix.filtered.vcf.gz.OK: $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n";
            }
            else
            {
                print MAK "$mvcfPrefix.filtered.vcf.gz.OK: \n";
            }

            runSVM($svcf, "$mvcfPrefix.filtered.sites.vcf");
        }

        # The following is always done per chr

        $cmd = getConf("VCFPASTE")." $mvcfPrefix.filtered.sites.vcf $mvcfPrefix.merged.vcf | ".getConf("BGZIP")." -c > $mvcfPrefix.filtered.vcf.gz";
        writeLocalCmd($cmd);
        $cmd = "\t".getConf("TABIX")." -f -pvcf $mvcfPrefix.filtered.vcf.gz\n";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "$cmd";
        $cmd = "\t".getConf("VCFSUMMARY")." --vcf $mvcfPrefix.filtered.sites.vcf --ref $ref --dbsnp ".getConf("DBSNP_VCF")." --FNRvcf ".getConf("HM3_VCF")." --chr $chr --tabix ".getConf("TABIX")." > $mvcfPrefix.filtered.sites.vcf.summary\n";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "$cmd";
        print MAK "\ttouch $mvcfPrefix.filtered.vcf.gz.OK\n\n";
        print MAK join("\n",@cmds);
        print MAK "\n";
    }

    if ( getConf("MERGE_BEFORE_FILTER") eq "TRUE" ) {
        #############################################################################
        ## STEP 10-4B : VCF PILEUP after MERGING
        #############################################################################
        if ( getConf("RUN_VCFPILEUP") eq "TRUE" ) {
            # determine whether to expand to lower level target or not
            my $expandFlag = ( getConf("RUN_GLFMULTIPLES") eq "TRUE" ) ? 1 : 0;

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
                #my $cmd = getConf("VCFPILEUP")." -i $svcf -r $ref -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
                my $cmd = getConf("VCFPILEUP")." -i $svcf -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
                $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                push(@cmds,"$pvcf.OK: $vcf.OK\n\tmkdir --p $pvcfParent\n\t".getMosixCmd($cmd)."\n\ttouch $pvcf.OK\n");
            }

            print MAK "pvcf$chr: ".join(".OK ",@pvcfs).".OK";
            if ( $expandFlag == 1 ) {
                print MAK " $remotePrefix$vcfDir/chr$chr/chr$chr.merged.vcf.OK\n\n";
            }
            else {
                print MAK "\n\n";
            }
            print MAK join("\n",@cmds);
        }

        #############################################################################
        ## STEP 10-5B : HARD FILTERING AFTER MERGING
        #############################################################################
        if ( getConf("RUN_FILTER") eq "TRUE" ) {
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

            my $expandFlag = ( getConf("RUN_VCFPILEUP") eq "TRUE" ) ? 1 : 0;
            my @cmds = ();
            my $cmd = getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/chr$chr/ --suffix .$chr.vcf.gz --outvcf $gvcf --index $bamIndexRemote 2> $gvcf.err";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;

            my $mvcfPrefix = "$remotePrefix$vcfDir/chr$chr/chr$chr";
            print MAK "filt$chr: $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n\n";
            if ( $expandFlag == 1 ) {
                print MAK "$mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK: $gvcf.OK pvcf$chr\n";
            }
            else {
                print MAK "$mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK: $gvcf.OK\n";
            }
            $cmd = "\t".getConf("VCFCOOKER")." ".getFilterArgs()." --indelVCF ".getConf("INDEL_PREFIX").".chr$chr.vcf --out $mvcfPrefix.${filterPrefix}filtered.sites.vcf --in-vcf $gvcf\n";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
            $cmd = getConf("VCFPASTE")." $mvcfPrefix.${filterPrefix}filtered.sites.vcf $mvcfPrefix.merged.vcf | ".getConf("BGZIP")." -c > $mvcfPrefix.${filterPrefix}filtered.vcf.gz";
            writeLocalCmd($cmd);
            $cmd = "\t".getConf("TABIX")." -f -pvcf $mvcfPrefix.${filterPrefix}filtered.vcf.gz\n";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
            $cmd = "\t".getConf("VCFSUMMARY")." --vcf $mvcfPrefix.${filterPrefix}filtered.sites.vcf --ref $ref --dbsnp ".getConf("DBSNP_VCF")." --FNRvcf ".getConf("HM3_VCF")." --chr $chr --tabix ".getConf("TABIX")." > $mvcfPrefix.${filterPrefix}filtered.sites.vcf.summary\n";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
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
        if ( getConf("RUN_VCFPILEUP") eq "TRUE" ) {
            my $expandFlag = ( getConf("RUN_GLFMULTIPLES") eq "TRUE" ) ? 1 : 0;

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
                    #my $cmd = getConf("VCFPILEUP")." -i $svcf -r $ref -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
                    my $cmd = getConf("VCFPILEUP")." -i $svcf -v $pvcf -b $bam > $pvcf.log 2> $pvcf.err";
                    $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                    push(@cmds,"$pvcf.OK: $svcf.OK\n\tmkdir --p $pvcfParent\n\t".getMosixCmd($cmd)."\n\ttouch $pvcf.OK\n");
                }
            }
            print MAK "pvcf$chr: ".join(".OK ",@pvcfs).".OK";
            if ( $expandFlag == 1 ) {
                print MAK " $remotePrefix$vcfDir/chr$chr/chr$chr.merged.vcf.OK\n\n";
            }
            else {
                print MAK "\n\n";
            }
            print MAK join("\n",@cmds);
        }

        #############################################################################
        ## STEP 10-5A : HARD FILTERING before MERGING
        #############################################################################
        if ( getConf("RUN_FILTER") eq "TRUE" ) {
            my $expandFlag = ( getConf("RUN_VCFPILEUP") eq "TRUE" ) ? 1 : 0;
            my $gmFlag = ( getConf("RUN_GLFMULTIPLES") eq "TRUE" ) ? 1 : 0;

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

                    my $cmd = getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]/ --suffix .$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz --outvcf $gvcf --index $bamIndexRemote 2> $gvcf.err";
                    $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                    push(@cmds,"$gvcf.OK: ".join(".OK ",@pvcfs).".OK".(($gmFlag == 1) ? " $vcf.OK" : "")."\n\t".getMosixCmd($cmd)."\n\ttouch $gvcf.OK\n\n");
                }
                else {
                    my $cmd = getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]/ --suffix .$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz --outvcf $gvcf --index $bamIndexRemote 2> $gvcf.err";
                    $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                    push(@cmds,"$gvcf.OK:".(($gmFlag == 1) ? " $vcf.OK" : "")."\n\t".getMosixCmd($cmd)."\n\ttouch $gvcf.OK\n\n");
                }
                push(@gvcfs,$gvcf);
                push(@vcfs,$vcf);
            }

            my $mvcfPrefix = "$remotePrefix$vcfDir/chr$chr/chr$chr";
            print MAK "filt$chr: $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n\n";
            print MAK "$mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK: ".join(".OK ",@gvcfs).".OK ".join(".OK ",@vcfs).".OK".(($gmFlag == 1) ? " $mvcfPrefix.merged.vcf.OK" : "")."\n";
            if ( $#uniqBeds < 0 ) {
                my $cmd = "\t".getConf("VCFMERGE")." $unitChunk @gvcfs > $mvcfPrefix.merged.stats.vcf\n";
                $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                print MAK "$cmd";
            }
            else {
                my $cmd = getConf("VCFCAT")." @gvcfs > $mvcfPrefix.merged.stats.vcf";
                writeLocalCmd($cmd);
            }
            my $cmd = "\t".getConf("VCFCOOKER")." ".getFilterArgs()." --indelVCF ".getConf("INDEL_PREFIX").".chr$chr.vcf --out $mvcfPrefix.${filterPrefix}filtered.sites.vcf --in-vcf $mvcfPrefix.merged.stats.vcf\n";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
            $cmd = getConf("VCFPASTE")." $mvcfPrefix.${filterPrefix}filtered.sites.vcf $mvcfPrefix.merged.vcf | ".getConf("BGZIP")." -c > $mvcfPrefix.${filterPrefix}filtered.vcf.gz";
            writeLocalCmd($cmd);
            $cmd = "\t".getConf("TABIX")." -f -pvcf $mvcfPrefix.${filterPrefix}filtered.vcf.gz\n";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
            $cmd = "\t".getConf("VCFSUMMARY")." --vcf $mvcfPrefix.${filterPrefix}filtered.sites.vcf --ref $ref --dbsnp ".getConf("DBSNP_VCF")." --FNRvcf ".getConf("HM3_VCF")." --chr $chr --tabix ".getConf("TABIX")." > $mvcfPrefix.${filterPrefix}filtered.sites.vcf.summary\n";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
            print MAK "\ttouch $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n\n";
            print MAK join("\n",@cmds);
            print MAK "\n";
        }
    }

    #############################################################################
    ## STEP 10-3 : GLFMULTIPLES
    #############################################################################
    if ( getConf("RUN_GLFMULTIPLES") eq "TRUE" ) {
        my $expandFlag = ( getConf("RUN_PILEUP") eq "TRUE" ) ? 1 : 0;
        my @cmds = ();
        my @vcfs = ();

        for(my $j=0; $j < @unitStarts; ++$j) {
            my $vcfParent = "$remotePrefix$vcfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
            my $vcf = "$vcfParent/chr$chr.$unitStarts[$j].$unitEnds[$j].vcf";
            my @glfs = ();
            my $smGlfParent = "$remotePrefix$smGlfDirReal/chr$chr/$unitStarts[$j].$unitEnds[$j]";
            my $smGlfParentCopy = ( $copyglf ? "$copyglf/chr$chr/$unitStarts[$j].$unitEnds[$j]" : $smGlfParent );

            handleGlfIndexFile($smGlfParentCopy, $smGlfParent, $chr, 
                               $unitStarts[$j], $unitEnds[$j]);

            for(my $i=0; $i < @allSMs; ++$i) {
                my $smGlfFn = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
                my $smGlf = "$smGlfParent/$smGlfFn";
                push(@glfs,$smGlf);
            }
            my $glfAlias = "$smGlfParent/".getConf("GLF_INDEX");
            $glfAlias =~ s/$outdir/\$(OUT_DIR)/g;
            push(@vcfs,$vcf);
            my $sleepSecs = ($j % 10)*$sleepMultiplier;
            my $cmd = getConf("GLFMULTIPLES")." --ped $glfAlias -b $vcf > $vcf.log 2> $vcf.err";
            if ( $copyglf ) {
                $cmd = "mkdir --p $copyglf/chr$chr && rsync -arv $smGlfParent $copyglf/chr$chr && $cmd && rm -rf $smGlfParentCopy";
            }
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            if ( $expandFlag == 1 ) {
                my $newcmd = "$vcf.OK: ".join(".OK ",@glfs).".OK\n\tmkdir --p $vcfParent\n";
                if($sleepSecs != 0)
                {
                    $newcmd .= "\tsleep $sleepSecs\n";
                }
                $newcmd .= "\t".getMosixCmd($cmd)."\n\ttouch $vcf.OK\n";
                $newcmd =~ s/$outdir/\$(OUT_DIR)/g;
                push(@cmds,"$newcmd");
            }
            else {
                my $newcmd = "$vcf.OK:\n\tmkdir --p $vcfParent\n";
                if($sleepSecs != 0)
                {
                    $newcmd .= "\tsleep $sleepSecs\n";
                }
                $newcmd .= "\t".getMosixCmd($cmd)."\n\ttouch $vcf.OK\n";
                push(@cmds,"$newcmd");
            }
        }
        my $out = "$vcfDir/chr$chr/chr$chr.merged";
        print MAK "vcf$chr: $remotePrefix$out.vcf.OK\n\n";
        print MAK "$remotePrefix$out.vcf.OK: ";
        print MAK join(".OK ",@vcfs);
        print MAK ".OK\n";
        if ( $#uniqBeds < 0 ) {
            my $cmd = "\t".getConf("VCFMERGE")." $unitChunk @vcfs > $out.vcf\n";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
        }
        else {  ## targeted regions - rely on the loci info
            my $cmd = getConf("VCFCAT")." @vcfs > $out.vcf";
            writeLocalCmd($cmd);
        }
        print MAK "\tcut -f 1-8 $out.vcf > $out.sites.vcf\n";
        print MAK "\ttouch $out.vcf.OK\n\n";
        print MAK join("\n",@cmds);
        print MAK "\n";
    }

    #############################################################################
    ## STEP 10-2 : SAMTOOLS PILEUP TO GENERATE GLF
    #############################################################################
    if ( getConf("RUN_PILEUP") eq "TRUE" ) {
        ## glf[$chr]: all-list-of-sample-glfs
        my @allSmGlfOKs = ();
        my @sampleCmds = ();
        my $bamPileupCmds = "";
        my $idxDependency = "";
        if (getConf("RUN_INDEX") eq "TRUE") { $idxDependency = " bai"; }

        # for each sample
        for(my $i=0; $i < @allSMs; ++$i) {
            my @bams = @{$hSM2bams{$allSMs[$i]}};
            # for each partition of the genome.
            for(my $j=0; $j < @unitStarts; ++$j)
            {
                # Set this region & loci information (if applicable) for doing the pileup(s).
                my $region = "$chr:$unitStarts[$j]-$unitEnds[$j]";
                my $loci = "";
                # Loci is only set if unique beds are used.
                if ( $#uniqBeds >= 0 ) {
                    my $idx = $hBedIndices{$allSMs[$i]};
                    $loci = "-l $targetDir/$uniqBedFns[$idx]/chr$chr/$chr.$unitStarts[$j].$unitEnds[$j].loci";
                    if ( getConf("SAMTOOLS_VIEW_TARGET_ONLY") eq "TRUE" ) {
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

                my $smGlfPartitionDir = "$remotePrefix$smGlfDir/chr$chr/$unitStarts[$j].$unitEnds[$j]";
                my $smGlfFilename = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
                my $smGlf = "$smGlfPartitionDir/$smGlfFilename";

                push(@allSmGlfOKs,"$smGlf.OK");

                # Start the sample glf target
                my $sampleCmd = "$smGlf.OK:$idxDependency";

                #Check how many BAMs there are.
                if($#bams == 0)
                {
                    # There is just one BAM for this sample.
                    if (getConf("BAM_DEPEND") eq "TRUE") { $sampleCmd .= " $bams[0]"; }
                    # Run pileup on this BAM and output as the sample GLF name.
                    $sampleCmd .= "\n\tmkdir --p $smGlfPartitionDir\n";
                    $sampleCmd .= logCatchFailure("pileup",
                                                  runPileup($bams[0], $smGlf, $region, $loci),
                                                  "$smGlf.log");
                }
                else
                {
                    # There is more than one BAM for this sample.
                    # Run pileup on each BAM, then merge together.
                    my @bamGlfs = ();
                    foreach my $bam (@bams)
                    {
                        # Output into BAM specific glfs.
                        my @F = split(/\//,$bam);
                        my $bamFn = pop(@F);
                        my $bamGlf = "$remotePrefix$bamGlfDir/$allSMs[$i]/chr$chr/$bamFn.$unitStarts[$j].$unitEnds[$j].glf";
                        push(@bamGlfs,$bamGlf);

                        # Add the target info for this pileup.

                        $bamPileupCmds .= "$bamGlf.OK:$idxDependency";
                        if (getConf("BAM_DEPEND") eq "TRUE") { $bamPileupCmds .= " $bam"; }
                        $bamPileupCmds .= "\n\tmkdir --p $bamGlfDir/$allSMs[$i]/chr$chr\n";
                        $bamPileupCmds .= logCatchFailure("pileup",
                                                          runPileup($bam, $bamGlf, $region, $loci),
                                                          "$bamGlf.log");
                        $bamPileupCmds .= "\ttouch $bamGlf.OK\n\n";
                    }
                    # Add the BAM specific GLFs to the sample glf dependency.
                    $sampleCmd .= " ".join(".OK ",@bamGlfs).".OK";
                    $sampleCmd .= "\n\tmkdir --p $smGlfPartitionDir\n\t";

                    my $qualities = "0";
                    my $minDepths = "1";
                    my $maxDepths = "1000";
                    for(my $k=1; $k < @bamGlfs; ++$k) {
                        $qualities .= ",0";
                        $minDepths .= ",1";
                        $maxDepths .= ",1000";
                    }
                    # Merge the multiple GLFs for this sample.
                    $sampleCmd .= getMosixCmd(getConf("GLFMERGE")." --qualities $qualities --minDepths $minDepths --maxDepths $maxDepths --outfile $smGlf @bamGlfs");
                    $sampleCmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                    $sampleCmd .= "\n";
                }
                $sampleCmd .= "\ttouch $smGlf.OK\n";
                push(@sampleCmds,$sampleCmd);
            }
        }

        print MAK "glf$chr: ";
        print MAK join(" ",@allSmGlfOKs);
        print MAK "\n\n";

        # Add the per sample commands
        print MAK join("\n",@sampleCmds);
        print MAK "\n";
        # Add the per BAM pileup commands
        print MAK "$bamPileupCmds";
    }
}

#############################################################################
## Check for WGS_SVM and handle that
############################################################################
if ( getConf("WGS_SVM") eq "TRUE")
{
    if( (scalar @wgsFilterDepSites) > 0 )
    {
        print MAK "$remotePrefix$vcfDir/filtered.vcf.gz.OK:$wgsFilterDepVcfs\n";

        my $mergedSites = "$remotePrefix$vcfDir/${filterPrefix}filtered.sites.vcf";
        my $outMergedVcf = "$remotePrefix$vcfDir/filtered.sites.vcf";

        # Add the vcf header.
        print MAK "\t".getConf("VCFCAT")." @wgsFilterDepSites > $mergedSites\n";

        # Run SVM on the merged file.
        runSVM($mergedSites, $outMergedVcf);

        # split svm file by chromosome.
        print MAK "\t".getConf("VCF_SPLIT_CHROM")." --in $outMergedVcf --out $remotePrefix$vcfDir/chrCHR/chrCHR.filtered.sites.vcf --chrKey CHR\n";
    }
}


#############################################################################
## STEP 10-1 : INDEX BAMS IF NECESSARY
#############################################################################
if ( getConf("RUN_INDEX") eq "TRUE" ) {
    my @bamsToIndex = ();
    if ( getConf("RUN_INDEX_FORCE") eq "TRUE" ) {
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
        my $cmd = getConf("SAMTOOLS_FOR_OTHERS")." index $bam";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "$bam.bai.OK:";
        if (getConf("BAM_DEPEND") eq "TRUE") { print MAK " $bam"; }
        print MAK "\n\t".getMosixCmd($cmd)."\n\ttouch $bam.bai.OK\n\n";
    }
}

close MAK;

print STDERR "--------------------------------------------------------------------\n";
print STDERR "Finished creating makefile $makef\n\n";

my $rc = 0;
if($numjobs != 0) {
    my $cmd = "make -k -f $makef -j $numjobs ". getConf("MAKE_OPTS") . " > $makef.log";
    if(($batchtype eq 'local') && ($numjobs > $maxlocaljobs))
    {
        die "ERROR: can't run $numjobs jobs with 'BATCH_TYPE = local', " .
            "max is $maxlocaljobs\n" .
            "Rerun with a different 'BATCH_TYPE' or override the local maximum ".
            "using '--maxlocaljobs $numjobs'\n" .
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


#--------------------------------------------------------------
#   handleGlfIndexFile(path, chrom, regionStart, regionEnd)
#
#   Create the glf index file for the specified region if:
#      * it does not exist
#      * it is older than the bam index file
#--------------------------------------------------------------
sub handleGlfIndexFile
{
    my ($smGlfParentCopy, $smGlfParent, $chr, $unitStart, $unitEnd) = @_;

    # Ensure the path exists.
    make_path($smGlfParent);

    my $glfIndexFile = "$smGlfParent/".getConf("GLF_INDEX");
    my $writeGlf = 1;
    # check if the glf index is already created.
    if(-r "$glfIndexFile")
    {
        # glfIndexFile exists, check if the first line is a match.
        open(AL,"<$glfIndexFile") || die "Cannot open file $glfIndexFile\n";
        my $firstLine = <AL>;
        close AL;
        if(1 <= @allSMs)
        {
            my $smGlfFn = "$allSMs[0].$chr.$unitStart.$unitEnd.glf";
            my $smGlf = "$smGlfParentCopy/$smGlfFn";
            my $expectedLine = "$allSMs[0]\t$allSMs[0]\t0\t0\t$hSM2sexs{$allSMs[0]}\t$smGlf\n";
            # don't write the glfIndex file if:
            #    1) the first line is identical to the expected line (checks for copyGlf changes)
            #    2) the glfIndexFile is newer than the bamIndex
            if( ($expectedLine eq $firstLine) && ( -M "$bamIndex" >= -M "$glfIndexFile" ) )
            {
                $writeGlf = 0;
            }
        }
    }

    if($writeGlf)
    {
        open(AL,">$glfIndexFile") || die "Cannot open file $glfIndexFile for writing\n";
        print STDERR "Creating glf INDEX at $chr:$unitStart-$unitEnd..\n";
        for(my $i=0; $i < @allSMs; ++$i) {
            my $smGlfFn = "$allSMs[$i].$chr.$unitStart.$unitEnd.glf";
            my $smGlf = "$smGlfParentCopy/$smGlfFn";
            print AL "$allSMs[$i]\t$allSMs[$i]\t0\t0\t$hSM2sexs{$allSMs[$i]}\t$smGlf\n";
        }
        close AL;
    }
}


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
        $filterArgs .= " --maxDP ".int($numSamples*$confValue);
    }

    $confValue = getIntConf('FILTER_MIN_SAMPLE_DP');
    if($confValue)
    {
        $filterArgs .= " --minDP ".int($numSamples*$confValue);
    }

    # Filter minNS.  First check if FILTER_MIN_NS is set.
    if(getIntConf('FILTER_MIN_NS'))
    {
        $filterArgs .= " --minNS ".getIntConf('FILTER_MIN_NS');
    }
    elsif(getIntConf('FILTER_MIN_NS_FRAC'))
    {
        $confValue = getIntConf('FILTER_MIN_NS_FRAC');
        if(($confValue < 0) || ($confValue > 1))
        {
            die "ERROR: FILTER_MIN_NS_FRAC must be between 0 & 1, but it ".
            "was: $confValue.\n";
        }
        my $minNS = $numSamples*$confValue;
        if($minNS < 1) { $minNS = 1;}
        else { $minNS = int($minNS); }
        $filterArgs .= " --minNS $minNS";
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

    # This hash's key is the vcfCooker filter name
    # and the value is the config file KEY name.
    # The value in the config file can be specified in multiple ways:
    #    1) as a single value - this is used as the filter value.
    #    2) as "val1, val2"
    #          val1 is used if numSamples < min samples
    #          val2 is used if numSamples > max samples
    #          a log formula is used if numSamples is between min & max samples
    # Set the filter KEY to blank or "off" to disable a default filter.
    my %filterArgHash = (
                         maxABL   => "FILTER_MAX_ABL",
                         maxSTR   => "FILTER_MAX_STR",
                         minSTR   => "FILTER_MIN_STR",
                         winIndel => "FILTER_WIN_INDEL",
                         maxSTZ   => "FILTER_MAX_STZ",
                         minSTZ   => "FILTER_MIN_STZ",
                         maxAOI   => "FILTER_MAX_AOI",
                         minFIC   => "FILTER_MIN_FIC",
                         maxCBR   => "FILTER_MAX_CBR",
                         maxLQR   => "FILTER_MAX_LQR",
                         minQual  => "FILTER_MIN_QUAL",
                         minMQ    => "FILTER_MIN_MQ",
                         maxMQ0   => "FILTER_MAX_MQ0",
                         maxMQ30  => "FILTER_MAX_MQ30",
                         maxAOZ   => "FILTER_MAX_AOZ",
                         maxIOR   => "FILTER_MAX_IOR",
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

    my $otherFilters = getConf("FILTER_ADDITIONAL");
    if($otherFilters)
    {
        $filterArgs .= " $otherFilters";
    }
    return $filterArgs;
}


#--------------------------------------------------------------
#   runSVM()
#
#   Run SVM on the specified file.
#--------------------------------------------------------------
sub runSVM
{
    my ($inVcf, $outVcf) = @_;
    my $cmd = "";
    if (getConf("USE_SVMMODEL") eq "TRUE")
    {
        $cmd = "\t".getConf("SVM_SCRIPT")." --invcf $inVcf --out $outVcf --model ".getConf("SVMMODEL")." --svmlearn ".getConf("SVMLEARN")." --svmclassify ".getConf("SVMCLASSIFY")." --bin ".getConf("INVNORM")." --threshold ".getConf("SVM_CUTOFF")." --bfile ".getConf("OMNI_VCF")." --bfile ".getConf("HM3_VCF")." --checkNA \n";
    }
    else
    {
        $cmd = "\t".getConf("SVM_SCRIPT")." --invcf $inVcf --out $outVcf --pos ".getConf("POS_SAMPLE")." --neg ".getConf("NEG_SAMPLE")." --svmlearn ".getConf("SVMLEARN")." --svmclassify ".getConf("SVMCLASSIFY")." --bin ".getConf("INVNORM")." --threshold ".getConf("SVM_CUTOFF")." --bfile ".getConf("OMNI_VCF")." --bfile ".getConf("HM3_VCF")." --checkNA \n";
    }

    $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
    print MAK "$cmd";
}

#--------------------------------------------------------------
#   runPileup()
#
#   Run Pileup on the specified file.
#--------------------------------------------------------------
sub runPileup
{
    my ($bamIn, $glfOut, $region, $loci) = @_;

    # Skip BAQ if the BAM filename contains any of the NOBAQ_SUBSTRINGS.
    my $baqFlag = 1;
    foreach my $s (@nobaqSubstrings)
    {
        if ( $bamIn =~ m/($s)/ )
        {
            $baqFlag = 0;
        }
    }

    my $baq = "";
    if ( $baqFlag != 0 ) {
        $baq .= " ".getConf("SAMTOOLS_FOR_OTHERS")." calmd -uAEbr - $ref |";
    }

    my $cmd = getMosixCmd("(".getConf("SAMTOOLS_FOR_OTHERS")." view ".getConf("SAMTOOLS_VIEW_FILTER")." -uh $bamIn $region |$baq ".getConf("BAMUTIL",1)." clipOverlap --in -.ubam --out -.ubam ".getConf("BAMUTIL_THINNING")." | ".getConf("SAMTOOLS_FOR_PILEUP")." pileup -f $ref $loci -g - > $glfOut) 2> $glfOut.log");

    $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
    return($cmd);
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

    $cmd =~ s/'/"/g;            # Avoid issues with single quotes in command
    my $newcmd = $runcluster." ";
    if($batchopts)
    {
        $newcmd .= "-opts '".$batchopts."' ";
    }
    $newcmd .= "$batchtype '$cmd'";
    return $newcmd;
}

#############################################################################
## writeLocalCmd() : Write a local command to the makefile
## This shoudl be used for short commands that can be executed on the local machine
############################################################################
sub writeLocalCmd {
    my $cmd = shift;

    # Replace gotcloudRoot with a Makefile variable.
    $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;

    # Check for pipes in the command.
    if( $cmd =~ /\|/)
    {
        $cmd =~ s/'/"/g;   # Avoid issues with single quotes in command
        my $newcmd = 'bash -c "set -e -o pipefail; '.$cmd.'"';
        print MAK "\t$newcmd\n";
    }
    else
    {
        print MAK "\t$cmd\n";
    }
}


#--------------------------------------------------------------
#   cmd = logCatchFailure(commandName, command, log, failVal)
#
#   Generate a line for a Makefile to generate an error message
#--------------------------------------------------------------
sub logCatchFailure {
    my ($commandName, $command, $log, $failVal) = @_;
    if (! defined($failVal)) { $failVal = 1; }

    my $makeCmd = "\t\@echo `date +'%F.%H:%M:%S'`\" $command\"\n" . "\t\@$command ";
    if ($failVal == 1) { $makeCmd .= '||'; }
    else { $makeCmd .= '&&'; }

    #   What caused the failure.
    $makeCmd .= " (echo \"`grep -i -e abort -e error -e failed $log`\" >&2; ";
    #   Show failed step.
    $makeCmd .= "echo \"Failed $commandName step\" >&2; ";
    #   Copy the log to the failed logs directory.
    $makeCmd .= "mkdir -p \$(OUT_DIR)/failLogs; cp $log \$(OUT_DIR)/failLogs/\$(notdir $log); ";
    #   Show log name to look at.
    $makeCmd .= "echo \"See \$(OUT_DIR)/failLogs/\$\(notdir $log\) for more details\" >&2; ";
    #   Exit on failure.
    $makeCmd .= "exit 1;)\n";
    if (getConf('KEEP_LOG')) { return $makeCmd; }

    #   On success, remove the log
#    $makeCmd .= "\trm -f $log\n";
    return $makeCmd;
}

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

umake.pl - Preform variant calling, generating VCF

=head1 SYNOPSIS

  umake.pl --test ~/testumake    # Run short self check
  umake.pl --conf ~/mydata.conf --outdir ~/testdir
  umake.pl --batchtype slurm --conf ~/mydata.conf


=head1 DESCRIPTION

Use this program to generate a Makefile which will run the programs
to perform variant calling to generate a single VCF for all samples.

There are many inputs to this script which are most often specified in a
configuration file.

The official documentation for this program can be found at
B<http://genome.sph.umich.edu/wiki/GotCloud:_Variant_Calling_Pipeline>

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

=item B<--conf file>

Specifies the configuration file to be used.
The default configuration is B<gotcloudDefaults.conf> found in the same directory
where this program resides.
If this file is not found, you must specify this option on the command line.

=item B<--help>

Generates this output.

=item B<--numjobs N>

The value of the B<-j> flag for the make command.
If not specified, the flag is not set on the make command to be executed.

=item B<--outdir dir>

Specifies the toplevel directory where the output is created.

=item B<--test outdir>

Run a small test case putting the output in the directory B<outdir> and verify the output.

=item B<--maxlocaljobs N>

Specifies the maximum number of jobs that can be run with batchtype local (the default).  Default is 10.

=item B<--snpcall>

Run the snpcall set of steps (pileup, glfmultiples, vcfpileup, filter, svm, split).

=item B<--extract>

Run the extract set of steps (pileup, glfextract, and split).

=item B<--beagle>

Run the beagle set of steps (beagle and subset).

=item B<--thunder>

Run thunder.

=item B<--index>

Run as if just RUN_INDEX was specified.

=item B<--pileup>

Run as if just RUN_PILEUP was specified.

=item B<--glfMultiples>

Run as if just RUN_GLFMULTIPLES was specified.

=item B<--vcfPileup>

Run as if just RUN_VCFPILEUP was specified.

=item B<--filter>

Run as if just RUN_FILTER was specified.

=item B<--svm>

Run as if just RUN_SVM was specified.

=item B<--split>

Run as if just RUN_SPLIT was specified.

=item B<--makebasename dir>

Specifies the basename for the makefile.

=item B<--region N:N-N>

Specifies the region (inclusive) on which to make calls. Format:  chr:start-end

=item B<--batchopts  options_string>

Specifies options to be passed to the batch engine.
You almost always will need to quote I<options_string>.
This is only valid if B<batchtype> is specified.

=item B<--batchtype local | slurm | sge | pbs | flux | mosix>

Specifies the batch system to be used when executing the commands.
These determine exactly how B<runcluster> will run the command.
the type 'flux' is an alias for 'pbs'.
The default is B<local>.

=item B<--ref_prefix dir>

This specifies a directory prefix which should be added to relative reference file paths.

=item B<--bam_prefix dir>

This specifies a directory prefix which should be added to relative paths in the bam index file.

=item B<--base_prefix dir>

This specifies a directory prefix which should be added to all relative paths if a different prefix is not specified.

=item B<--verbose>

Specifies that additional details are to be printed out.

=item B<--copyglf dir>

Specifies the directory that glf files should be copied to prior to running glfExtract/glfMultiples.  This can be used when running on a cluster if it would be faster to copy the glfs locally first.

=item B<--chrs str>

Comma separated list of choromsomes to process.  Overrides the 'CHRS' configuration setting.

=item B<--gotcloudroot dir>

Specifies an alternate path to other gotcloud files rather than using the path to this script.

=back

=head1 PARAMETERS

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

