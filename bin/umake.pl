#!/usr/bin/env perl

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
use IO::Zlib;
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
my $beagleOpt = "";
my $thunderOpt = "";
my $beagle4Opt = "";
my $split4Opt = "";
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
my $ignoreSmCheck = '';
my $noPhoneHome = '';

my $bamList = '';
my $refdir = '';

# Track if any of the "bams" are crams.
my %isCram = ();
my $chunkOK = '';

my $optResult = GetOptions("help",\$help,
                           "test=s",\$testdir,
                           "outdir|out_dir=s",\$outdir,
                           "conf=s",\$conf,
                           "list|bam_list|bamlist=s",\$bamList,
                           "numjobs=i",\$numjobs,
                           "maxlocaljobs=i",\$maxlocaljobs,
                           "snpcall",\$snpcallOpt,
                           "beagle",\$beagleOpt,
                           "thunder",\$thunderOpt,
                           "beagle4",\$beagle4Opt,
                           "split4",\$split4Opt,
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
                           "refdir|ref_dir=s", \$refdir,
                           "ignoresmcheck", \$ignoreSmCheck,
                           "gotcloudroot|gcroot=s", \$gcroot,
                           "noPhoneHome", \$noPhoneHome,
                           "chunkOK", \$chunkOK
    );

my $usage = "Usage:\tgotcloud snpcall --conf [conf.file]\n".
"\tgotcloud ldrefine --conf [conf.file]\n".
"\tgotcloud vc --conf [conf.file]\n".
"Specify --help to get more usage infromation";
die "Error in parsing options\n$usage\n" unless ( ($optResult) && (($conf) || ($bamList) || ($help) || ($testdir)) );

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
        open my $openFile, '<', $file or die "Cannot open $file file for reading: $!";
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
    my $origTestDir = $testdir;
    my $outdir=abs_path($testdir);
    system("mkdir -p $outdir") &&
        die "Unable to create directory '$outdir'\n";

    $testdir = $gotcloudRoot . '/test/umake';
    # First check that the test directory exists.
    if(! -r $testdir)
    {
        die "ERROR, '$testdir' does not exist, please download the test data to that directory\n";
    }
    my $cmd = "$0 --conf $testdir/umake_test.conf ";

    my $testoutdir = $outdir."/umaketest";
    my $rmdir = $testoutdir;

    my $diffScript = "$gotcloudRoot/scripts/diff_results_umake.sh";
    my $expecteddir = "$testdir/expected";

    my $type = "";
    if($snpcallOpt)
    {
        $type = "snpcall";
    }
    if($beagleOpt)
    {
        # Verify that first the snpcall test was run.
        my $checkFile = "$testoutdir/split/chr20/chr20.filtered.PASS.split.vcflist.OK";
        if(! -r $checkFile)
        {
            die "ERROR, $checkFile does not exist, first run snpcall test\n\tgotcloud snpcall --test $origTestDir\n";
        }

        $type = "beagle";
        # Just remove the beagle & thunder subdirectories.
        $rmdir .= "/*beagle* $outdir/umaketest/*thunder*";
    }
    if($thunderOpt)
    {
        # Verify that first the beagle test was run.
        my $checkFile = "$testoutdir/thunder/chr20/ALL/split/chr20.filtered.PASS.beagled.ALL.split.vcflist.OK";
        if(! -r $checkFile)
        {
            die "ERROR, $checkFile does not exist, first run beagle test\n\tgotcloud beagle --test $origTestDir\n";
        }

        $type = "thunder";
        # Just remove the thunder subdirectory.
        $rmdir .= "/thunder/chr20/ALL/thunder";
    }
    if($split4Opt)
    {
        # Verify that first the snpcall test was run.
        my $checkFile = "$testoutdir/split/chr20/chr20.filtered.PASS.split.vcflist.OK";
        if(! -r $checkFile)
        {
            die "ERROR, $checkFile does not exist, first run snpcall test\n\tgotcloud snpcall --test $origTestDir\n";
        }

        $type = "split4";
        # Remove the remove the beagle subdirectory.
        $rmdir .= "/*split4* $outdir/umaketest/*beagle4*";
    }
    if($beagle4Opt)
    {
        # Verify that first the split4 test was run.
        my $checkFile = "$testoutdir/split4/chr20/chr20.filtered.PASS.split.list.OK";
        if(! -r $checkFile)
        {
            die "ERROR, $checkFile does not exist, first run split4 test\n\tgotcloud snpcall --test $origTestDir\n";
        }

        $type = "beagle4";
        # Just remove the beagle4 subdirectory.
        $rmdir .= "/*beagle4*";
    }

    $cmd .= "--$type ";
    if($gcroot)
    {
        $cmd .= "--gotcloudRoot $gcroot ";
    }


    print "Removing any previous results from: $testoutdir\n";
    system("rm -rf $rmdir") &&
        die "Unable to clear the test output directory '$rmdir'\n";
    print "Running GOTCLOUD TEST, test log in: $testoutdir.log\n";

    $cmd .= "--outdir $testoutdir --numjobs 2 1> $testoutdir.log 2>&1";
    system($cmd) &&
        die "Failed to generate test data. Not a good thing.\nCMD=$cmd\n";
    $cmd = "$diffScript $outdir $expecteddir $type";
    system($cmd) &&
        die "Comparison failed, test case FAILED.\nCMD=$cmd\n";
    print "Successfully ran the test case, congratulations!\n";
    exit;
}

#--------------------------------------------------------------
#   Convert command line options to conf settings
#--------------------------------------------------------------
#   Set the configuration values for applicable command-line options.
if ($bamList)    { push(@confSettings, "BAM_LIST = $bamList"); }
if ($bamprefix)  { push(@confSettings, "BAM_PREFIX = $bamprefix"); }
if ($refprefix)  { push(@confSettings, "REF_PREFIX = $refprefix"); }
if ($baseprefix) { push(@confSettings, "BASE_PREFIX = $baseprefix"); }
if ($makebasename)   { push(@confSettings, "MAKE_BASE_NAME = $makebasename"); }
if ($outdir)     { push(@confSettings, "OUT_DIR = $outdir"); }
if ($copyglf)    { push(@confSettings, "COPY_GLF = $copyglf"); }
if ($refdir)     { push(@confSettings, "REF_DIR = $refdir"); }
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
if(!$ignoreSmCheck)
{
    $ignoreSmCheck = getConf("IGNORE_SM_CHECK");
}

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
## BEAGLE  : BEAGLE -> SUBSET : 8,9
## THUNDER : THUNDER -> 10
## BEAGLE4 : SPLIT4 -> BEAGLE4 : 11 12
my @orders = qw(RUN_INDEX RUN_PILEUP RUN_GLFMULTIPLES RUN_VCFPILEUP RUN_FILTER RUN_SVM RUN_SPLIT RUN_BEAGLE RUN_SUBSET RUN_THUNDER RUN_SPLIT4 RUN_BEAGLE4);
my @orderFlags = ();

## if --snpcall --beagle --subset or --thunder
if ( ( $snpcallOpt) || ( $beagleOpt ) || ( $thunderOpt ) ||
     ($indexOpt) || ($pileupOpt) || ($glfMultiplesOpt) || ($vcfPileupOpt) ||
     ($filterOpt) || ($svmOpt) || ($splitOpt) || ($beagle4Opt) || ($split4Opt) ) {
    foreach my $o (@orders) {
        push(@orderFlags, 0);
        setConf($o, "FALSE");
    }
    if ( $snpcallOpt ) {
        foreach my $i (1,2,3,4,5,6) { # PILEUP to SPLIT
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $beagleOpt ) {
        foreach my $i (7,8) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $thunderOpt ) {
        foreach my $i (9) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $beagle4Opt ) {
        foreach my $i (11) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
    if ( $split4Opt ) {
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
        foreach my $i (6) {
            $orderFlags[$i] = 1;
            setConf($orders[$i], "TRUE");
        }
    }
}
else {
    foreach my $o (@orders) {
        setConf($o, (uc getConf($o)));
        push(@orderFlags, (getConf($o) eq "TRUE") ? 1 : 0 );
    }
}

## check if the current orders are compatible with any of the valid orders
my @validOrders = ([0,1,2,3,4,5,6],[7,8],[9],[10,11]);
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
print STDERR "BAM_LIST:      ".getConf("BAM_LIST")."\n";
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
    die "ERROR IN CONF FILE : Options are not compatible. Use --snpcall, --beagle, --thunder, --beagle4 or compatible subsets\n";
}

if ( $numSteps == 0 ) {
    die "ERROR IN CONF FILE : No option is given. Manually configure STEPS_TO_RUN section in the configuration file, or use --snpcall, --beagle, --thunder, --beagle4 or compatible subsets\n";
}

#--------------------------------------------------------------
#   Check required settings
#--------------------------------------------------------------
# Check to see if the old REF is set instead of the new one.
my %deprecatedDie = (
    FA_REF => "REF",
    DBSNP_PREFIX => "DBSNP_VCF",
    HM3_PREFIX => "HM3_VCF",
    OUTPUT_DIR => "OUT_DIR",
    OUT_PREFIX => "MAKE_BASE_NAME",
);
my $failReqFile = "0";
foreach my $key (keys %deprecatedDie)
{
    if(getConf("$key"))
    {
        warn "ERROR: '$key' is deprecated and has been replaced by '$deprecatedDie{$key}', please update your configuration file and rerun\n";
        $failReqFile = "1";
    }
}

if($failReqFile eq "1")
{
    die "Exiting pipeline due to deprecated settings, please fix & rerun\n";
}

my %deprecatedWarn = (
    BAM_INDEX => "BAM_LIST",
);

foreach my $key (keys %deprecatedWarn)
{
    if(getConf("$key"))
    {
        warn "WARNING: '$key' is deprecated and has been replaced by '$deprecatedWarn{$key}'\n";
    }
}

if(getConf("BAM_INDEX"))
{
    setConf("BAM_LIST", getConf("BAM_INDEX"));
}
elsif(!getConf("BAM_LIST"))
{
    warn "ERROR: 'BAM_LIST' required, but not set.\n";
    $failReqFile = "1";
}

#   These files must exist
my @reqRefs = qw(REF);

# RUN_SVM & RUN_FILTER need dbsnp & HM3 files
if( (getConf("RUN_SVM") eq "TRUE") ||
    (getConf("RUN_FILTER") eq "TRUE") )
{
    push(@reqRefs, "DBSNP_VCF");
    push(@reqRefs, "HM3_VCF");
}

if(getConf("RUN_SVM") eq "TRUE")
{
    push(@reqRefs, "OMNI_VCF");
}


my @refVcfs;
foreach my $f (@reqRefs)
{

    # Replace the path with the absolute path
    my $newPath = getAbsPath(getConf($f), 'REF');
    setConf($f, $newPath);
    push(@refVcfs, $newPath);
    # Check that the path exists.
    if (-r $newPath) { next; }
    warn "ERROR: Could not read required $f: $newPath\n";
    $failReqFile = "1";
}


#############################################################################
## Read FASTA INDEX file to determine chromosome size
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

my @toClean = ();

my @chrs = split(/\s+/,getConf("CHRS"));
my @chrchrs;
foreach my $chr (@chrs)
{
    # Check if $chr already starts with chr.
    my $chrchr = "chr$chr";
    if($chr =~ /^chr/)
    {
        $chrchr = $chr;
    }
    push(@chrchrs, $chrchr);

    if(! exists $hChrSizes{$chr})
    {
        my $newChr = "chr$chr";
        if(exists $hChrSizes{$newChr})
        {
            die "ERROR: REF file, $fai, has $newChr, but CHRS has $chr.  Chromosome names must be consistent.\n";
            }
        $newChr = $chr;
        $newChr =~ s/^chr//;
        if(exists $hChrSizes{$newChr})
        {
            die "ERROR: REF file, $fai, has $newChr, but CHRS has $chr.  Chromosome names must be consistent.\n";
        }
        die "ERROR: REF file, $fai, does not have $chr, but CHRS has $chr.  Chromosome names must be consistent.\n";
    }
}

if ( getConf("RUN_FILTER") eq "TRUE" )
{
    # If INDEL_VCF is specified, use that instead of INDEL_PREFIX.
    if(getConf("INDEL_VCF"))
    {
        my $newPath = getAbsPath(getConf("INDEL_VCF"), "REF");
        setConf("INDEL_VCF", $newPath);
        # Only VcfCooker takes INDEL_VCF and it works with either chr or non-chr chromosome names
        # even if other files have the other type of name, so no need to validate the chromosome names.

        # Check that the path exists.
        if (! -r $newPath)
        {
            warn "ERROR: Could not read required 'INDEL_VCF': $newPath\n";
            warn "\tDid you mean to use 'INDEL_PREFIX' instead?  If so, unset INDEL_VCF.\n";
            $failReqFile = "1";
        }
    }
    else
    {
        # convert the INDEL_PREFIX to an absolute path.
        my $newpath = getAbsPath(getConf("INDEL_PREFIX"), "REF");
        setConf("INDEL_PREFIX", $newpath);
        # check for the INDEL files for each chromosome
        for (my $i = 0; $i < @chrs; $i++)
        {
            my $chrchr = $chrchrs[$i];
            my $chr = $chrs[$i];
            my $vcf = getConf("INDEL_PREFIX").".$chrchr.vcf";
            if(! -r $vcf)
            {
                warn "ERROR: Could not read required indel file based on INDEL_PREFIX for $chrchr: $vcf\n";
                $failReqFile = "1";
            }
            else{
                # Check that the VCF has the correct chromosome.
                open(VCF, $vcf);
                while(<VCF>)
                {
                    next if(/^#/);
                    my ($vcfchr) = split(/[\t\n]+/);
                    # Single chromsome, so only check one record.
                    if($vcfchr ne $chr)
                    {
                        die "ERROR: $vcf has $vcfchr, but CHRS has $chr.  Chromosome names must be consistent.\n";
                    }
                    # Since the vcf is just for a single chromosome,
                    # only need to check one record.
                    last;
                }
                close(VCF);
            }
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
                  'RUN_GLFMULTIPLES' => [qw(GLFFLEX VCFMERGE)],
                  'RUN_FILTER' => [qw(INFOCOLLECTOR VCFCOOKER VCFPASTE BGZIP TABIX VCFSUMMARY VCFMERGE)],
                  'RUN_VCFPILEUP' => [qw(VCFPILEUP)],
                  'RUN_SVM' => [qw(VCFPASTE BGZIP TABIX VCFSUMMARY SVM_SCRIPT SVMLEARN SVMCLASSIFY INVNORM VCF_SPLIT_CHROM)],
                  'RUN_SPLIT' => [qw(BGZIP VCFSPLIT)],
                  'RUN_SPLIT4' => [qw(BGZIP VCFSPLIT4)],
                  'RUN_BEAGLE'=> [qw(LIGATEVCF BGZIP TABIX VCF2BEAGLE BEAGLE BEAGLE2VCF)],
                  'RUN_BEAGLE4'=> [qw(LIGATEVCF4 BEAGLE4)],
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
elsif($beagleOpt)
{
    $makeext = "beagle";
}
elsif($thunderOpt)
{
    $makeext = "thunder";
}
elsif($beagle4Opt)
{
    $makeext = "beagle4";
}
elsif($split4Opt)
{
    $makeext = "split4";
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
$bamList = getAbsPath(getConf("BAM_LIST"));
my $pedIndex = getConf("PED_INDEX");
my %hSM2bams = ();  # hash mapping sample IDs to bams
my %hSM2pops = ();  # hash mapping sample IDs to bams
my %hSM2sexs = ();  # hash mapping sample IDs to bams
my @allbams = ();   # list of all bamss
my @allbamSMs = (); # list of all samples corresponding to each BAM
my @allSMs = ();    # list of all unique sample IDs
my %bams2Sm = ();    # Maps bam to sample id
my %hPops = ();
my $numSamples = 0;
my $noPop = 0; # number of lines with no populations, should end up 0 or equal to $numSamples.

open(IN,$bamList) || die "Cannot open $bamList file\n";
while(<IN>) {
    my ($smID,$pop,@bams) = split;
    next if(!defined $smID); # Skip empty line

    # fail if there is no population or are no BAMs specified.
    if(!defined $pop)
    {
        die "ERROR: Check the format of $bamList.  It should be at least 2 columns (sample, bams or sample, population, bams), but it is only 1 column.\n";
    }

    # Population is optional, so check pop to see if it looks like a BAM/CRAM.
    if($pop =~ /(bam|BAM|cram|CRAM)$/)
    {
        # No population, just a BAM/CRAM, add it to the list of bams, and 
        # set population to ALL.
        unshift(@bams,$pop);
        $pop = "ALL";
        ++$noPop;
    }
    elsif(scalar @bams == 0)
    {
        die "ERROR: Check the format of $bamList.  It should be at least 3 columns (sample, population, bams), or if population is skipped, the bams/crams in the 2nd column should end in 'bam', 'BAM', 'cram', or 'CRAM'.\n";
    }

    # Make sure the sample id doesn't look like bam/cram file names.
    if($smID =~ /\.(bam|BAM|cram|CRAM)$/)
    {
        die "ERROR: Check the format of $bamList.\nFirst column should be the sample name, but it looks like a bam file.\n\tExample: $smID\n";
    }

    my @mpops = split(/,/,$pop);

    if ( defined($hSM2pops{$smID}) || defined($hSM2bams{$smID}) ) {
        die "ERROR: Duplicated sample ID $smID in $bamList\n".
        "All BAMs for a SampleID should be on one line\n";
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

        if(exists ($bams2Sm{$bam}))
        {
            die "ERROR: A BAM can only appear once in the BAM_LIST, but $bam appears multiple times in $bamList\n";
        }
        $bams2Sm{$bam} = $smID;

        # If a step that requires the BAMs is being used, check
        # that the BAMs can be read.
        if ( (getConf("RUN_INDEX") eq "TRUE") ||
             (getConf("RUN_PILEUP") eq "TRUE") ||
             (getConf("RUN_VCFPILEUP") eq "TRUE") )
        {
            # die if bam is not readable
            unless ( -r $bam ) { die "ERROR: Cannot read BAM file, '$bam'\n"; }
            unless ( -s $bam ) { die "ERROR: $bam' is empty.\n"; }
        }
    }
    push(@allSMs,$smID);
    push(@allbams,@bams);
}

if(scalar @allbams == 0)
{
    die "ERROR: no BAMs to process, check your bam list.\n";
}

close IN;

$numSamples = @allSMs;

if(($noPop ne 0) && ($noPop ne $numSamples))
{
    die "ERROR: All entries in BAM_LIST, $bamList, must consistently either have a population column or not have a population column.  It cannot be mixed.\n";
}
my $infoCollectorSkipList = "--skipList 2";
if($noPop eq $numSamples)
{
    # No population column to be skipped, so just skip the sample name column.
    $infoCollectorSkipList = "--skipList 1";
}

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
## STEP 2a : Check for valid number of samples
############################################################################
# Beagle & Thunder cannot run on single samples.
if(($numSamples < 2) && ((getConf("RUN_BEAGLE") eq "TRUE") || (getConf("RUN_BEAGLE4") eq "TRUE") || (getConf("RUN_THUNDER") eq "TRUE")))
{
    die "\nERROR: ldrefine, beagle, thunder, and beagle4 require at least 2 samples, but there is only $numSamples sample in $bamList.\n\n";
}


#############################################################################
## STEP 3 : Create MAKEFILE
############################################################################

my $makef = getConf("OUT_DIR")."/".getConf("MAKE_BASE_NAME").".$makeext.Makefile";
my $makef_OUT_DIR = $makef;
$makef_OUT_DIR =~ s/$outdir/\$(OUT_DIR)/g;


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
## Determine Regions.
############################################################################
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

#----------------------------------------------------------------------------
# Check for consistancy in chromosome naming.
#----------------------------------------------------------------------------
my %fileChrs = ();
# Check the bam files for valid chromosomes (must be found in the ref fai file).
for my $bam (@allbams)
{
    die "ERROR: Cannot open file $bam: $!\n" unless ( -s $bam );
    tie *BAM, "IO::Zlib", $bam, "rb";

    # Read 4 bytes (magic string)
    my $buffer;
    read(BAM, $buffer, 4);
    if($buffer ne "BAM\1")
    {
        # Check if it is a CRAM file.
        if($buffer eq "CRAM")
        {
            # This bam is a cram.
            $isCram{$bam} = 1;

            # Check for cram index.
            if ( (getConf("RUN_PILEUP") eq "TRUE") ||
                 (getConf("RUN_VCFPILEUP") eq "TRUE") )
            {
                # die if cram index is not readable
                my $crai = "$bam.crai";
                unless ( -r $crai ) { die "ERROR: Cannot read CRAM.crai file, '$crai'\n"; }
                unless ( -s $crai ) { die "ERROR: $crai' is empty.\n"; }
            }

            # TODO, validate CRAM.
            next;
        }
        #use bytes;
        #printf '%02x ', ord substr $buffer, 3, 1;
        die "$bam is not a proper BAM file, magic != BAM\\1, instead it is ".$buffer."\n";
    }
    # Check for BAM index.
    if ( (getConf("RUN_PILEUP") eq "TRUE") ||
         (getConf("RUN_VCFPILEUP") eq "TRUE") )
    {
        # die if bai is not readable
        my $bai = "$bam.bai";
        my $bai2 = $bam;
        $bai2 =~ s/\.bam$/.bai/;
        unless ( -r $bai || -r $bai2 ) { die "ERROR: Cannot read BAM.bai file, '$bai'\n"; }
        unless ( -s $bai || -s $bai2 ) { die "ERROR: $bai' is empty.\n"; }
    }


    # Read the length of the header text.
    read(BAM, $buffer, 4);
    my $hdrLen = unpack("V", $buffer);
    # Read the header.
    read(BAM, $buffer, $hdrLen);
    my $hdr = unpack("Z*", $buffer);

    # Parse the header looking for RG fields to check samples.
    my @hdrSMs = ($hdr =~ m/^\@RG\t.*SM:([^\n\t\r]*)/g);
    my $numSMs = scalar @hdrSMs;
    if($numSMs > 0)
    {
        if($numSMs > 1)
        {
            for(my $i = 1; $i < $numSMs; ++$i)
            {
                if($hdrSMs[$i] ne $hdrSMs[0])
                {
                    die "ERROR: GotCloud only supports BAMs with a single sample, but $bam has multiple samples, '$hdrSMs[0]' and '$hdrSMs[$i]'\n";
                }
            }
        }

        # Validate the Sample name matches the one in the BAM_LIST.
        if(!$ignoreSmCheck && ($bams2Sm{$bam} ne $hdrSMs[0]))
        {
            die "ERROR: Sample name, '$hdrSMs[0]' found in $bam does not match the one in $bamList, '$bams2Sm{$bam}'\n";
        }
    }

    # Read the number of reference sequences
    read(BAM, $buffer, 4);
    my $numRef = unpack("V", $buffer);

    # Read the length of the sequence names.
    for(my $i = 0; $i < $numRef; ++$i)
    {
        # Read the length of the ref name.
        read(BAM, $buffer, 4);
        my $refNameLen = unpack("V", $buffer);
        read(BAM, $buffer, $refNameLen);
        my $chr = unpack("Z*", $buffer);

        $fileChrs{$bam}{$chr} = 1;

        read(BAM, $buffer, 4);
        my $refLen = unpack("V", $buffer);
    }
}

# Check the VCFs for matching chromosomes in the .fai file.
for my $refVcf (@refVcfs)
{
    next if($refVcf !~ /\.vcf(\.gz)?$/); # Not a vcf file.

    # Get TBI
    my $refTbi = "$refVcf.tbi";

    # TBI files are bgziped
    die "ERROR: Cannot open file $refTbi: $!\n" unless ( -s $refTbi );
    tie *REFTBI, "IO::Zlib", $refTbi, "rb";

    # Read 4 bytes (magic string)
    my $buffer;
    read(REFTBI, $buffer, 4);
    if($buffer ne "TBI\1")
    {
        #use bytes;
        #printf '%02x ', ord substr $buffer, 3, 1;
        die "$refTbi is not a proper TBI file, magic != TBI\\1, instead it is ".$buffer."\n";
    }

    # Read the next 7 int32_t and throw them away.
    read(REFTBI, $buffer, 28);
    # Read the length of the sequence names.

    read(REFTBI, $buffer, 4);
    my $length = unpack("V", $buffer);

    read(REFTBI, $buffer, $length);
    foreach my $chr (unpack("(Z*)*", $buffer))
    {
        $fileChrs{$refVcf}{$chr} = 1;
    }
    close(REFTBI);
}

foreach my $chr (@chrs)
{
    foreach my $file ( sort keys %fileChrs)
    {
        if(!exists $fileChrs{$file}{$chr})
        {
            my $newChr = "chr$chr";
            if(exists $fileChrs{$file}{$newChr})
            {
                die "ERROR: $file has $newChr, but CHRS has $chr.  Chromosome names must be consistent.\n";
            }
            $newChr = $chr;
            $newChr =~ s/^chr//;
            if(exists $fileChrs{$file}{$newChr})
            {
                die "ERROR: $file has $newChr, but CHRS has $chr.  Chromosome names must be consistent.\n";
            }
            die "ERROR: $file does not have $chr, but CHRS has $chr.  Chromosome names must be consistent.\n";
        }
    }
}


#############################################################################
## Check MD5 files for CRAM.
############################################################################
# If there are any CRAM files, set REF_PATH.
if(scalar keys %isCram > 0)
{
    # There is at least one CRAM file, so check the MD5 files.
    genMD5Files();

    # Check each CRAM and see if it's MD5 file exists.
    my %refM5s = ();
    foreach my $cram (sort(keys %isCram))
    {
        open my $input, "-|", getConf("SAMTOOLS_FOR_OTHERS")." view -H $cram | grep \"^\@SQ\""
        or die "samtools failed to read header from $cram: $!";
        while(my $line = <$input>)
        {
            chomp $line;
            $line =~ /M5:([0-9a-fA-F]*)/;
            my $m5 = $1;
            $line =~ /SN:([^\t]*)/;
            $refM5s{$m5} = $1;
        }
    }
    foreach my $refM5 (sort (keys %refM5s))
    {
        # Only validate for chromosomes in the reference.
        # We already validated that all processed chromosomes are in the reference.
        if(!exists $hChrSizes{$refM5s{$refM5}})
        {
            next;
        }
        my $refPath = getConf("MD5_DIR");
        while($refPath =~ /([^%]*)%([0-9]*)s(.*)/)
        {
            my $sub = $refM5;
            if($2)
            {
               $sub = substr($refM5, 0, $2);
               $sub = substr($refM5, 0, $2, "");
            }
            $refPath = $1.$sub.$3;
        }
        if(! -e $refPath)
        {
            die "ERROR: unable to find MD5 file at $refPath expected for a CRAM file, ensure 'REF' matches the one used to generate the CRAMs.\n";
        }
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
my $vcfDirReal = "$outdir/".getConf("VCF_DIR");
my $pvcfDir = "\$(OUT_DIR)/".getConf("PVCF_DIR");
my $splitDir = "\$(OUT_DIR)/".getConf("SPLIT_DIR");
my $splitDirReal = "$outdir/".getConf("SPLIT_DIR");
my $targetDir = "\$(OUT_DIR)/".getConf("TARGET_DIR");
my $targetDirReal = "$outdir/".getConf("TARGET_DIR");
my $beagleDir = "\$(OUT_DIR)/".getConf("BEAGLE_DIR");
my $beagle4Dir = "\$(OUT_DIR)/".getConf("BEAGLE4_DIR");
my $split4Dir = "\$(OUT_DIR)/".getConf("SPLIT4_DIR");
my $split4DirReal = "$outdir/".getConf("SPLIT4_DIR");
my $thunderDir = "\$(OUT_DIR)/".getConf("THUNDER_DIR");
my $thunderDirReal = "$outdir/".getConf("THUNDER_DIR");
my $remotePrefix = getConf("REMOTE_PREFIX");

my $bamListRemote = ($bamList =~ /^\//) ? "$remotePrefix$bamList" : ($remotePrefix.getcwd()."/".$bamList);

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
# add prefix to SVM if doing single sample
my $svmPrefix = "";
my $extfilt = "FALSE";
if(getConf("EXT"))
{
    $extfilt = "TRUE";
    $svmPrefix = "SVM";
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
    my $offTarget = getIntConf("OFFSET_OFF_TARGET");
    # If OFFSET_OFF_TARGET is not set, default to 0.
    if(!$offTarget)
    {
        $offTarget = 0;
    }
    my $r = parseTarget($bed, $offTarget);
    push(@targetIntervals,$r);
}

#############################################################################
## ITERATE EACH CHROMOSOME
############################################################################
foreach my $chr (@chrs) {
    my $chrchr = shift (@chrchrs);
    print STDERR "Generating commands for $chrchr...\n";
    if(!defined($hChrSizes{$chr}))
    {
        if($chr =~ /^chr/)
        {
            my $tmpChr = $chr;
            $tmpChr =~ s/^chr//;
            if(defined($hChrSizes{$tmpChr}))
            {
                die "Cannot find chromosome name, '$chr', in the reference file (ref has '$tmpChr').  Set 'CHRS' consistent with the reference file.\n";
            }
        }
        else
        {
            if(defined($hChrSizes{"chr".$chr}))
            {
                die "Cannot find chromosome name, '$chr', in the reference file (ref has '$chrchr').  Set 'CHRS' consistent with the reference file.\n";
            }
        }
        die "Cannot find chromosome name, '$chr', in the reference file\n";
    }
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
            if ( defined($callstart) )
            {
                if ( $start < $callstart)
                {
                    $start = $callstart;
                }
                if ( $callend < $end )
                {
                    $end = $callend;
                }
            }
            push(@unitStarts,$start);
            push(@unitEnds,$end);
        }
    }

    if(scalar @unitStarts == 0)
    {
        die "ERROR: no regions in chromosome $chr.  Fix the problem or remove it from CHRS & rerun.\n";
    }

    #############################################################################
    ## STEP 9 : WRITE .loci file IF NECESSARY
    #############################################################################
    if ( ($#uniqBeds >= 0) && (getConf("RUN_PILEUP") eq "TRUE") )
    {
        ## Generate target loci information
        for(my $i=0; $i < @uniqBeds; ++$i) {
            my $printBedName = 0;
            my $outDir = "$targetDirReal/$uniqBedFns[$i]/$chrchr";
            make_path($outDir);
            for(my $j=0; $j < @unitStarts; ++$j) {
                # Write the loci file if:
                #   1) it does not exist
                #   2) the bed file is newer than the loci file
                #   3) the bed file is not the same one used to create the previous loci file
                my $bedNameFile = "$outDir/$chr.$unitStarts[$j].$unitEnds[$j].txt";
                my $bedName = "";
                if(-r $bedNameFile)
                {
                    # Check: 3) the bed file is not the same one used to create the previous loci file
                    open(FILE, $bedNameFile) or die "Can't read file '$bedNameFile' [$!]\n";  
                    $bedName = <FILE>;  # bed name on first line.
                    chomp $bedName;
                    close (FILE);
                }

                if( (! -r "$outDir/$chr.$unitStarts[$j].$unitEnds[$j].loci") ||
                    ( -M "$uniqBeds[$i]" < -M "$outDir/$chr.$unitStarts[$j].$unitEnds[$j].loci" ) ||
                    ( $bedName ne $uniqBeds[$i] ) )
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
                    open(my $bedfh, '>', $bedNameFile) or die "Could not open file '$bedNameFile' $!";
                    print $bedfh "$uniqBeds[$i]\n";
                    close $bedfh;
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
    print MAK " beagle4_$chr" if ( getConf("RUN_BEAGLE4") eq "TRUE" );
    print MAK " split$chr" if ( getConf("RUN_SPLIT") eq "TRUE" );
    print MAK " split4_$chr" if ( getConf("RUN_SPLIT4") eq "TRUE" );
    print MAK " extFilt$chr" if ( $extfilt eq "TRUE" );
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
            my $thunderPrefix = "$thunderDir/$chrchr/$pop/thunder/$chrchr.filtered.PASS.beagled.$pop.thunder";
            print MAK " $thunderPrefix.vcf.gz.tbi";
        }
        print MAK "\n\n";

        foreach my $pop (@pops) {
            my $splitPrefix = "$thunderDirReal/$chrchr/$pop/split/$chrchr.filtered.PASS.beagled.$pop.split";
            open(IN,"$splitPrefix.vcflist") || die "Cannot open $splitPrefix.vcflist for thunder\n";
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

            if($nsplits <= 0)
            {
                die "WARNING: No VCFs to process, nothing for Thunder to do.\n";
            }

            my $thunderPrefix = "$thunderDir/$chrchr/$pop/thunder/$chrchr.filtered.PASS.beagled.$pop.thunder";
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
                print MAK "\tmkdir --p $thunderDir/$chrchr/$pop/thunder\n";
                my $cmd = getConf("THUNDER")." --shotgun $splitVcfs[$i] -o $remotePrefix$thunderOut > $remotePrefix$thunderOut.out 2> $remotePrefix$thunderOut.err";
                $cmd =~ s/$outdir/\$(OUT_DIR)/g;
                $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                print MAK "\t".getMosixCmd($cmd, "$thunderOut.vcf.gz")."\n";
                writeTouch("$thunderOut.vcf.gz");
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
            print MAK " $thunderDir/$chrchr/$pop/split/$chrchr.filtered.PASS.beagled.$pop.split.vcflist.OK";
        }
        print MAK "\n\n";

        my $nLdSNPs = getConf("LD_NSNPS");
        my $nLdOverlap = getConf("LD_OVERLAP");
        my $mvcf = "$remotePrefix$vcfDir/$chrchr/$chrchr.filtered.vcf.gz";

        if ( $expandFlag == 1 ) {
            print MAK "$beagleDir/$chrchr/subset.OK: beagle$chr\n";
        }
        else {
            print MAK "$beagleDir/$chrchr/subset.OK:\n";
        }
        my $beaglePrefix = "$beagleDir/$chrchr/$chrchr.filtered.PASS.beagled";
        if ( $#pops > 0 ) {
            my $cmd = getConf("VCFCOOKER")." --in-vcf $remotePrefix$beaglePrefix.vcf.gz --out $remotePrefix$beaglePrefix --subset --in-subset $bamListRemote --bgzf > $remotePrefix$beaglePrefix.subset.out 2>&1";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$beagleDir/$chrchr/subset")."\n";
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
        writeTouch("$beagleDir/$chrchr/subset", "$remotePrefix$beaglePrefix.$pops[0].vcf.gz");

        foreach my $pop (@pops) {
            my $splitPrefix = "$thunderDir/$chrchr/$pop/split/$chrchr.filtered.PASS.beagled.$pop.split";
            print MAK "$splitPrefix.vcflist.OK: $beagleDir/$chrchr/subset.OK\n";
            print MAK "\tmkdir --p $thunderDir/$chrchr/$pop/split/\n";
            my $cmd = getConf("VCFSPLIT")." --in $remotePrefix$beaglePrefix.$pop.vcf.gz --out $remotePrefix$splitPrefix --nunit $nLdSNPs --noverlap $nLdOverlap 2> $remotePrefix$splitPrefix.err";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$splitPrefix.vcflist")."\n";
            writeTouch("$splitPrefix.vcflist");
        }
    }

    #############################################################################
    ## STEP 10-7 : RUN BEAGLE GENOTYPE REFINEMENT
    #############################################################################
    if ( getConf("RUN_BEAGLE") eq "TRUE" ) {
        my $beaglePrefix = "$beagleDir/$chrchr/$chrchr.filtered.PASS.beagled";
        print MAK "beagle$chr: $beaglePrefix.vcf.gz.tbi\n\n";

        my $splitPrefix = "$splitDirReal/$chrchr/$chrchr.filtered.PASS.split";
        open(IN,"$splitPrefix.vcflist") || die "Cannot open $splitPrefix.vcflist for beagle\n";
        my @splitVcfs = ();
        while(<IN>) {
            chomp;
            push(@splitVcfs,$_);
        }
        close IN;
        my $nsplits = $#splitVcfs+1;

        if($nsplits <= 0)
        {
            die "WARNING: No VCFs to process, nothing for Beagle to do.\n";
        }

        my @beagleOuts = ();
        my $beagleOutPrefix = "$beagleDir/$chrchr/split/bgl";
        for(my $i=0; $i < $nsplits; ++$i) {
            my $j = $i+1;
            my $beagleOut = "$beagleOutPrefix.$j.$chrchr.PASS.$j";
            push(@beagleOuts,$beagleOut);
        }

        print MAK "$beaglePrefix.vcf.gz.tbi: ".join(".vcf.gz.tbi ",@beagleOuts).".vcf.gz.tbi\n";
        my $cmd = getConf("LIGATEVCF")." ".join(".vcf.gz ",@beagleOuts).".vcf.gz 2> $beaglePrefix.vcf.gz.err | ".getConf("BGZIP")." -c > $beaglePrefix.vcf.gz";
        writeLocalCmd($cmd);
        $cmd = getConf("TABIX")." -f -pvcf $beaglePrefix.vcf.gz";
        writeLocalCmd($cmd);
        print MAK "\n";

        my $beagleLikeDir = "$beagleDir/$chrchr/like";
        for(my $i=0; $i < $nsplits; ++$i) {
            my $j = $i+1;
            my $beagleOut = "$beagleOutPrefix.$j.$chrchr.PASS.$j";
            print MAK "$beagleOut.vcf.gz.tbi:\n";
            print MAK "\tmkdir --p $beagleLikeDir\n";
            print MAK "\tmkdir --p $beagleDir/$chrchr/split\n";
            my $sleepSecs = $i*$sleepMultiplier % 1000;
            if($sleepSecs != 0)
            {
                print MAK "\tsleep ".$sleepSecs."\n";
            }
            my $cmd = getConf("VCF2BEAGLE")." --in $splitVcfs[$i] --out $remotePrefix$beagleLikeDir/$chrchr.PASS.$j.gz";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$remotePrefix$beagleLikeDir/$chrchr.PASS.$j.gz")."\n";
            $cmd = getConf("BEAGLE")." like=$remotePrefix$beagleLikeDir/$chrchr.PASS.".($i+1).".gz out=$remotePrefix$beagleOutPrefix.$j >$remotePrefix$beagleOutPrefix.$j.out 2>$remotePrefix$beagleOutPrefix.$j.err";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$remotePrefix$beagleOutPrefix.$j")."\n";
            $cmd = getConf("BEAGLE2VCF"). " --filter --beagle $remotePrefix$beagleOut.gz --invcf $splitVcfs[$i] --outvcf $remotePrefix$beagleOut.vcf";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$remotePrefix$beagleOut.vcf")."\n";
            $cmd = getConf("BGZIP"). " -f $remotePrefix$beagleOut.vcf";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$remotePrefix$beagleOut.vcf.gz")."\n";
            $cmd = getConf("TABIX"). " -f -pvcf $remotePrefix$beagleOut.vcf.gz";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$remotePrefix$beagleOut.vcf.gz.tbi")."\n";
            print MAK "\n";
        }
    }

    #############################################################################
    ## STEP 10-6 : SPLIT FILTERED VCF INTO CHUNKS FOR GENOTYPING
    #############################################################################
    if ( getConf("RUN_SPLIT") eq "TRUE" ) {
        # determine whether to expand to lower level target or not
        my $expandFlag = ( getConf("RUN_FILTER") eq "TRUE" ) ? 1 : 0;
        $expandFlag = 2 if ( getConf("RUN_SVM") eq "TRUE" );

        print MAK "split$chr:";
        my $splitPrefix = "$splitDir/$chrchr/$chrchr.filtered.PASS.split";
        print MAK " $splitPrefix.vcflist.OK";
        print MAK "\n\n";

        my $nLdSNPs = getConf("LD_NSNPS");
        my $nLdOverlap = getConf("LD_OVERLAP");
        my $mvcf = "$remotePrefix$vcfDir/$chrchr/$chrchr.filtered.vcf.gz";

        my $subsetPrefix = "$splitDir/$chrchr/$chrchr.filtered";
        if ( $expandFlag == 2 ) {
            print MAK "$splitDir/$chrchr/subset.OK: $remotePrefix$vcfDir/$chrchr/$chrchr.filtered.vcf.gz.OK\n";
        }
        else {
            print MAK "$splitDir/$chrchr/subset.OK:\n";
        }
        print MAK "\tmkdir --p $splitDir/$chrchr\n";
        my $cmd = "zcat $mvcf | grep -E \\\"[[:space:]]PASS[[:space:]]|^#\\\" | ".getConf("BGZIP")." -c > $subsetPrefix.PASS.vcf.gz";
        writeLocalCmd($cmd);
        writeTouch("$splitDir/$chrchr/subset", "$subsetPrefix.PASS.vcf.gz");

        print MAK "$splitPrefix.vcflist.OK: $splitDir/$chrchr/subset.OK\n";
        print MAK "\tmkdir --p $splitDir/$chrchr\n";
        $cmd = getConf("VCFSPLIT")." --in $remotePrefix$subsetPrefix.PASS.vcf.gz --out $remotePrefix$splitPrefix --nunit $nLdSNPs --noverlap $nLdOverlap 2> $remotePrefix$splitPrefix.err";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "\t".getMosixCmd($cmd, "$splitPrefix.vcflist")."\n";
        writeTouch("$splitPrefix.vcflist");
    }

    #############################################################################
    ## STEP 10-7a : RUN BEAGLE4 GENOTYPE REFINEMENT
    #############################################################################
    if ( getConf("RUN_BEAGLE4") eq "TRUE" ) {
        my $beagleVcf = "$beagle4Dir/$chrchr/$chrchr.filtered.PASS.beagled.vcf.gz";
        print MAK "beagle4_$chr: $beagleVcf.tbi.OK\n\n";

        my $splitPrefix = "$split4DirReal/$chrchr/$chrchr.filtered.PASS.split";

        my @splitVcfs = ();
        my $listFile = "$splitPrefix.list";

        open(IN,"$listFile") || die "Cannot open $listFile for beagle4\n";
        while(<IN>) {
            chomp;
            my @F = split;
            push(@splitVcfs, $F[$#F]);
        }
        close IN;
        my $nsplits = $#splitVcfs+1;
        if($nsplits <= 0)
        {
            die "WARNING: No VCFs to process, nothing for Beagle to do.\n";
        }

	my $mvcf = "$remotePrefix$vcfDir/$chrchr/$chrchr.filtered.vcf.gz";
        my $beagleLikeDir = "$beagle4Dir/$chrchr/like";
        my @beagleOuts = ();
        for(my $i=0; $i < $nsplits; ++$i) {
            my $j = $i+1;
            my $beagleOut = "$remotePrefix$beagleLikeDir/$chrchr.PASS.$j.vcf.gz";
            push(@beagleOuts,$beagleOut);
        }

        print MAK "$beagleVcf.tbi.OK: ".join(".tbi.OK ",@beagleOuts).".tbi.OK\n";
        my $cmd = getConf("LIGATEVCF4")." --list $remotePrefix$listFile -bgl $remotePrefix$beagleLikeDir/$chrchr.PASS --vcf $mvcf --out $remotePrefix$beagleVcf";
        $cmd =~ s/$outdir/\$(OUT_DIR)/g;
        writeLocalCmd($cmd);
        $cmd = getConf("TABIX")." -f -pvcf $beagleVcf";
        $cmd =~ s/$outdir/\$(OUT_DIR)/g;
        writeLocalCmd($cmd);
        writeTouch("$beagleVcf.tbi.OK");
        print MAK "\n";

        for(my $i=0; $i < $nsplits; ++$i) {
            my $j = $i+1;
            my $beagleOut = "$remotePrefix$beagleLikeDir/$chrchr.PASS.$j";
            print MAK "$beagleOut.vcf.gz.tbi.OK:\n";
            print MAK "\tmkdir --p $beagleLikeDir\n";
            my $sleepSecs = sprintf("%.2lf",$sleepMultiplier*rand(1000));
            if($sleepSecs != 0)
            {
                print MAK "\tsleep ".$sleepSecs."\n";
            }

            my $cmd = getConf("BEAGLE4")." gl=$splitVcfs[$i] out=$beagleOut";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$beagleOut.vcf.gz")."\n";
            $cmd = getConf("TABIX"). " -f -pvcf $beagleOut.vcf.gz";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$beagleOut.vcf.gz.tbi")."\n";
            writeTouch("$beagleOut.vcf.gz.tbi.OK");
            print MAK "\n";
        }
    }

    #############################################################################
    ## STEP 10-6a : SPLIT4 FILTERED VCF INTO CHUNKS FOR GENOTYPING
    #############################################################################
    if ( getConf("RUN_SPLIT4") eq "TRUE" ) {
        # determine whether to expand to lower level target or not
        my $expandFlag = ( getConf("RUN_FILTER") eq "TRUE" ) ? 1 : 0;
        $expandFlag = 2 if ( getConf("RUN_SVM") eq "TRUE" );

        print MAK "split4_$chr:";
        my $splitPrefix = "$split4Dir/$chrchr/$chrchr.filtered.PASS.split";

        my $listFile = "$splitPrefix.list";
        print MAK " $listFile.OK";
        print MAK "\n\n";

        my $nLdSNPs = getConf("LD_NSNPS");
        my $nLdOverlap = getConf("LD_OVERLAP");
        my $mvcf = "$remotePrefix$vcfDir/$chrchr/$chrchr.filtered.vcf.gz";

        my $subsetPrefix = "$split4Dir/$chrchr/$chrchr.filtered";

        my $dep = "";
        if ( $expandFlag == 2 ) {
            $dep = " $remotePrefix$vcfDir/$chrchr/$chrchr.filtered.vcf.gz.OK";
        }

        my $splitCmd = "";
        $splitCmd = &getConf("VCFSPLIT4")." --vcf $mvcf --out $remotePrefix$splitPrefix --win $nLdSNPs --overlap $nLdOverlap 2> $remotePrefix$splitPrefix.err";

        print MAK "$listFile.OK:$dep\n";
        print MAK "\tmkdir --p $split4Dir/$chrchr\n";

        $splitCmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "\t".getMosixCmd($splitCmd, "$listFile")."\n\n";
        writeTouch("$listFile");
    }



    #############################################################################
    ## STEP 10.5 : RUN SVM FILTERING
    #############################################################################
    if ( getConf("RUN_SVM") eq "TRUE") {
        my $vcfParent = "$remotePrefix$vcfDir/$chrchr";
        my $vcfPrefix = "$vcfParent/$chrchr";

        $vcfPrefix =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;

        my $svmvcf = "$vcfPrefix.${svmPrefix}filtered.vcf.gz";
        my $svmsitesvcf = "$vcfPrefix.${svmPrefix}filtered.sites.vcf";
        #############################################################################
        ## STEP 10.5a : RUN single FILTERING after SVM
        #############################################################################
        if ( $extfilt eq "TRUE") {
            my $outvcf = "$vcfPrefix.filtered.vcf.gz";
            my $outsitesvcf = "$vcfPrefix.filtered.sites.vcf";

            print MAK "extFilt$chr: $outvcf.OK\n\n";

            print MAK "$outvcf.OK: $svmvcf.OK\n";

            my @exts = split(/\s+/, getConf("EXT", 1));
            my $extStr = "";
            my $chrSub = getConf("EXT_CHR_SUB");
            foreach my $ext (@exts)
            {
                chomp $ext;
                if($chrSub)
                {
                    $ext =~ s/$chrSub/$chr/g;
                    if(! -r $ext)
                    {
                        die "ERROR, EXT file, '$ext', does not exist\nReminder, EXT is space delimited.\n";
                    }
                }
                $extStr .= " --ext $ext";
            }

            my $cmd = getConf("EXT_FILT")." --ref ".getConf("REF")." --in $svmvcf ${extStr} --out $outvcf 2> $outvcf.err";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "\t".getMosixCmd($cmd, "$outvcf")."\n";
            $cmd = getConf("TABIX")." -f -pvcf $outvcf";
            writeLocalCmd($cmd);
            # Write just the sites, then do the summary.
            print MAK "\tzcat $outvcf | cut -f 1-8 > $outsitesvcf\n";
            $cmd = "\t".getConf("VCFSUMMARY")." --vcf $outsitesvcf --ref $ref --dbsnp ".getConf("DBSNP_VCF")." --FNRvcf ".getConf("HM3_VCF")." --chr $chr --tabix ".getConf("TABIX")." > $outsitesvcf.summary 2> $outsitesvcf.summary.log\n";
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
            $cmd = getConf("BGZIP")." -f $outsitesvcf";
            writeLocalCmd($cmd);
            $cmd = getConf("TABIX")." -f -pvcf $outsitesvcf.gz";
            writeLocalCmd($cmd);
            writeTouch("$outvcf");
            print MAK "\n";
        }

        # Regular SVM
        my $hardfiltsitesvcf = "$vcfPrefix.${filterPrefix}filtered.sites.vcf";
        my $hardfiltvcf = "$vcfPrefix.${filterPrefix}filtered.vcf.gz";
        my $mergedvcf = "$vcfPrefix.merged.vcf";

        my $expandFlag = ( getConf("RUN_FILTER") eq "TRUE" ) ? 1 : 0;

        print MAK "svm$chr: $svmvcf.OK\n\n";

        my $cmd = "";

        if ( getConf("WGS_SVM") eq "TRUE")
        {
            print MAK "$svmvcf.OK: $remotePrefix$vcfDir/${svmPrefix}filtered.vcf.gz.OK\n";
            push(@wgsFilterDepSites, "$hardfiltsitesvcf");
            $wgsFilterDepVcfs .= " $hardfiltvcf.OK";
        }
        else
        {
            if ( $expandFlag == 1 ) {
                print MAK "$svmvcf.OK: $hardfiltvcf.OK\n";
            }
            else
            {
                print MAK "$svmvcf.OK: \n";
            }

            runSVM($hardfiltsitesvcf, "$vcfPrefix.${svmPrefix}filtered.sites.vcf");
        }

        # The following is always done per chr

        $cmd = getConf("VCFPASTE")." $svmsitesvcf $mergedvcf | ".getConf("BGZIP")." -c > $svmvcf";
        writeLocalCmd($cmd);
        $cmd = "\t".getConf("TABIX")." -f -pvcf $svmvcf\n";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "$cmd";
        $cmd = "\t".getConf("VCFSUMMARY")." --vcf $svmsitesvcf --ref $ref --dbsnp ".getConf("DBSNP_VCF")." --FNRvcf ".getConf("HM3_VCF")." --chr $chr --tabix ".getConf("TABIX")." > $svmsitesvcf.summary 2> $svmsitesvcf.summary.log\n";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "$cmd";
        unless ($extfilt eq "TRUE") {
            $cmd = getConf("BGZIP")." -f $vcfPrefix.filtered.sites.vcf";
            writeLocalCmd($cmd);
            $cmd = getConf("TABIX")." -f -pvcf $vcfPrefix.filtered.sites.vcf.gz";
            writeLocalCmd($cmd);
        }
        writeTouch("$svmvcf");
        print MAK "\n";

        for(my $j=0; $j < @unitStarts; ++$j) {
            my $vcfParent = "$remotePrefix$vcfDir/$chrchr/$unitStarts[$j].$unitEnds[$j]";
            push(@toClean,$vcfParent);
        }
        push(@toClean,"$vcfPrefix.merged.*") if ( getConf("RUN_SVM") eq "TRUE" );
        push(@toClean,"$vcfPrefix.${filterPrefix}filtered.*") if ( getConf("RUN_SVM") eq "TRUE" );
        push(@toClean,"$vcfPrefix.${svmPrefix}filtered.*") if ( $extfilt eq "TRUE" );
    }

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

        my $cptdir = "$outdir/cpt/".getConf("PVCF_DIR")."/$chrchr";
        system("mkdir -p $cptdir") && die "Unable to create directory '$cptdir'\n";
        my $cptMAKdir = $cptdir;
        $cptMAKdir =~ s/$outdir/\$(OUT_DIR)/g;

        my @svcfs = ();
        for(my $j=0; $j < @unitStarts; ++$j) {
            my $vcfParent = "$remotePrefix$vcfDir/$chrchr/$unitStarts[$j].$unitEnds[$j]";
            my $svcf = "$vcfParent/$chrchr.$unitStarts[$j].$unitEnds[$j].sites.vcf";
            my $gvcf = "$vcfParent/$chrchr.$unitStarts[$j].$unitEnds[$j].stats.vcf";
            my $vcf = "$vcfParent/$chrchr.$unitStarts[$j].$unitEnds[$j].vcf";
            my $pvcfParent = "$pvcfDir/$chrchr/$unitStarts[$j].$unitEnds[$j]";
            push(@cmds,"$svcf.OK: ".( ($expandFlag == 1) ? "$vcf.OK" : "")."\n\tcut -f 1-8 $vcf > $svcf\n\tmkdir --p $pvcfParent\n\t".getTouch("$svcf")."\n");
            push(@svcfs, $svcf);
        }

        my @allcpts = ();
        for(my $i=0; $i < @allbams; ++$i) {
            my $bam = $allbams[$i];
            my $bamSM = $allbamSMs[$i];
            my @F = split(/\//,$bam);
            my $bamFn = pop(@F);

            my $cptOK = "$cptMAKdir/$bamFn.OK";
            push(@allcpts, $cptOK);
            my $singleOKCmd = "";
            for(my $j=0; $j < @unitStarts; ++$j) {
                my $pvcfParent = "$pvcfDir/$chrchr/$unitStarts[$j].$unitEnds[$j]";
                my $pvcf = "$remotePrefix$pvcfParent/$bamFn.$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz";
                my $cmd;
                my $vcfInBam = $bam;
                if(exists $isCram{$bam})
                {
                    # Cram has to be converted to bam and streamed to vcfPileup
                    $cmd = "REF_PATH=".getConf("MD5_DIR")." ".getConf("SAMTOOLS_FOR_OTHERS")." view -uh $bam $chr:$unitStarts[$j]-$unitEnds[$j] | ";
                    $vcfInBam = "-.ubam";
                }
                $cmd .= getConf("VCFPILEUP")." -i $svcfs[$j] -v $pvcf -b $vcfInBam > $pvcf.log 2> $pvcf.err";
                $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                if( $chunkOK) {
                    push(@pvcfs,$pvcf);
                    push(@cmds,"$pvcf.OK: $svcfs[$j].OK\n\t".getMosixCmd($cmd, "$pvcf")."\n\t".getTouch("$pvcf")."\n");
                }
                else {
                    if($singleOKCmd ne "")
                    {
                        $singleOKCmd .= " && ";
                    }
                    $singleOKCmd .= $cmd;
                }
            }
            if(! $chunkOK)
            {
                push(@cmds, "$cptOK: ".join(".OK ",@svcfs).".OK");
                push(@cmds, "\t".getMosixCmd($singleOKCmd,$cptOK));
                push(@cmds, "\ttouch $cptOK\n");
            }
        }

        print MAK "pvcf$chr: $cptMAKdir/all.OK\n\n";

        if ( $chunkOK ) {
            my $line = "$cptMAKdir/all.OK: ".join(".OK ",@pvcfs).".OK";
            $line =~ s/$outdir/\$(OUT_DIR)/g;
            print MAK $line;
        }
        else {
            my $line = "$cptMAKdir/all.OK: ".join(" ",@allcpts);
            $line =~ s/$outdir/\$(OUT_DIR)/g;
            print MAK $line;
        }
        if ( $expandFlag == 1 ) {
            print MAK " $remotePrefix$vcfDir/$chrchr/$chrchr.merged.vcf.OK\n";
        }
        else {
            print MAK "\n";
        }
        print MAK "\ttouch $cptMAKdir/all.OK\n\n";
        print MAK join("\n",@cmds);
        print MAK "\n";
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

        my $cptdir = "$outdir/cpt/".getConf("PVCF_DIR")."/$chrchr";
        my $cptMAKdir = $cptdir;
        $cptMAKdir =~ s/$outdir/\$(OUT_DIR)/g;

        for(my $j=0; $j < @unitStarts; ++$j) {
            my $vcfParent = "$remotePrefix$vcfDir/$chrchr/$unitStarts[$j].$unitEnds[$j]";
            my $svcf = "$vcfParent/$chrchr.$unitStarts[$j].$unitEnds[$j].sites.vcf";
            my $gvcf = "$vcfParent/$chrchr.$unitStarts[$j].$unitEnds[$j].stats.vcf";
            my $vcf = "$vcfParent/$chrchr.$unitStarts[$j].$unitEnds[$j].vcf";

            if ( $expandFlag > 0 ) {
                my $cmd = getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/$chrchr/$unitStarts[$j].$unitEnds[$j]/ --suffix .$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz --outvcf $gvcf --list $bamListRemote $infoCollectorSkipList 2> $gvcf.err";
                $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;

                push(@cmds,"$gvcf.OK: $cptMAKdir/all.OK".(($gmFlag == 1) ? " $vcf.OK" : "")."\n\t".getMosixCmd($cmd, "$gvcf")."\n\t".getTouch("$gvcf")."\n\n");
            }
            else {
                my $cmd = getConf("INFOCOLLECTOR")." --anchor $vcf --prefix $remotePrefix$pvcfDir/$chrchr/$unitStarts[$j].$unitEnds[$j]/ --suffix .$chr.$unitStarts[$j].$unitEnds[$j].vcf.gz --outvcf $gvcf --list $bamListRemote $infoCollectorSkipList 2> $gvcf.err";
                $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                push(@cmds,"$gvcf.OK:".(($gmFlag == 1) ? " $vcf.OK" : "")."\n\t".getMosixCmd($cmd, "$gvcf")."\n\t".getTouch("$gvcf")."\n\n");
            }
            push(@gvcfs,$gvcf);
            push(@vcfs,$vcf);
        }

        my $mvcfPrefix = "$remotePrefix$vcfDir/$chrchr/$chrchr";
        print MAK "filt$chr: $mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK\n\n";
        print MAK "$mvcfPrefix.${filterPrefix}filtered.vcf.gz.OK: ".join(".OK ",@gvcfs).".OK ".join(".OK ",@vcfs).".OK".(($gmFlag == 1) ? " $mvcfPrefix.merged.vcf.OK" : "")."\n";
        if ( $#uniqBeds < 0 ) {
            my $cmd = "\t".getConf("VCFMERGE")." $unitChunk @gvcfs > $mvcfPrefix.merged.stats.vcf 2> $mvcfPrefix.merged.stats.vcf.log\n";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
        }
        else {
            my $cmd = getConf("VCFCAT")." @gvcfs > $mvcfPrefix.merged.stats.vcf";
            writeLocalCmd($cmd);
        }
        my $indelVCF = getConf("INDEL_PREFIX").".$chrchr.vcf";
        if(getConf("INDEL_VCF"))
        {
            $indelVCF = getConf("INDEL_VCF");
        }

        my $cmd = "\t".getConf("VCFCOOKER")." ".getFilterArgs()." --indelVCF $indelVCF --out $mvcfPrefix.${filterPrefix}filtered.sites.vcf --in-vcf $mvcfPrefix.merged.stats.vcf > $mvcfPrefix.${filterPrefix}filtered.sites.vcf.out 2>&1\n";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "$cmd";
        $cmd = getConf("VCFPASTE")." $mvcfPrefix.${filterPrefix}filtered.sites.vcf $mvcfPrefix.merged.vcf | ".getConf("BGZIP")." -c > $mvcfPrefix.${filterPrefix}filtered.vcf.gz";
        writeLocalCmd($cmd);
        $cmd = "\t".getConf("TABIX")." -f -pvcf $mvcfPrefix.${filterPrefix}filtered.vcf.gz\n";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "$cmd";
        $cmd = "\t".getConf("VCFSUMMARY")." --vcf $mvcfPrefix.${filterPrefix}filtered.sites.vcf --ref $ref --dbsnp ".getConf("DBSNP_VCF")." --FNRvcf ".getConf("HM3_VCF")." --chr $chr --tabix ".getConf("TABIX")." > $mvcfPrefix.${filterPrefix}filtered.sites.vcf.summary 2> $mvcfPrefix.${filterPrefix}filtered.sites.vcf.summary.log\n";
        $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
        print MAK "$cmd";
        if ($filterPrefix eq "")
        {
            $cmd = getConf("BGZIP")." -f $mvcfPrefix.filtered.sites.vcf";
            writeLocalCmd($cmd);
            $cmd = getConf("TABIX")." -f -pvcf $mvcfPrefix.filtered.sites.vcf.gz";
            writeLocalCmd($cmd);
        }
        writeTouch("$mvcfPrefix.${filterPrefix}filtered.vcf.gz");
        print MAK join("\n",@cmds);
        print MAK "\n";
    }


    #############################################################################
    ## STEP 10-3 : GLFMULTIPLES
    #############################################################################
    if ( getConf("RUN_GLFMULTIPLES") eq "TRUE" ) {
        my $expandFlag = ( getConf("RUN_PILEUP") eq "TRUE" ) ? 1 : 0;
        my @cmds = ();
        my @vcfs = ();

        my $invcf = getConf("VCF_EXTRACT");
        if ( $invcf ) {
            unless ( ( $invcf =~ /.gz$/ ) && ( -s $invcf ) && ( -s "$invcf.tbi" ) ) {
                die "Input VCF file $invcf must be bgzipped and tabixed\n";
            }
        }

        my $glfsingle = ( getConf("MODEL_GLFSINGLE") eq "TRUE" ? " --glfsingle" : "");
        my $skipDetect = ( getConf("MODEL_SKIP_DISCOVER") eq "TRUE" ? " --skipDetect" : "");
        my $afPrior = ( getConf("MODEL_AF_PRIOR") eq "TRUE" ? " --afprior" : "");

        for(my $j=0; $j < @unitStarts; ++$j) {
            my $vcfParent = "$remotePrefix$vcfDirReal/$chrchr/$unitStarts[$j].$unitEnds[$j]";
            my $vcf = "$vcfParent/$chrchr.$unitStarts[$j].$unitEnds[$j].vcf";
            my $smGlfParent = "$remotePrefix$smGlfDirReal/$chrchr/$unitStarts[$j].$unitEnds[$j]";
            my $smGlfParentCopy = ( $copyglf ? "$copyglf/$chrchr/$unitStarts[$j].$unitEnds[$j]" : $smGlfParent );

            handleGlfIndexFile($smGlfParentCopy, $smGlfParent, $vcfParent, $chr, 
                               $unitStarts[$j], $unitEnds[$j]);

            my $glfAlias = "$vcfParent/".getConf("GLF_INDEX");
            $glfAlias =~ s/$outdir/\$(OUT_DIR)/g;
            push(@vcfs,$vcf);
            my $sleepSecs = ($j % 10)*$sleepMultiplier;
            my $cmd = getConf("GLFFLEX")." --ped $glfAlias -b $vcf ".($invcf ? "--positionfile $invcf --region $chr:$unitStarts[$j]-$unitEnds[$j] " : "")."$glfsingle $skipDetect $afPrior > $vcf.log 2> $vcf.err";
            if ( $copyglf ) {
                $cmd = "mkdir --p $copyglf/$chrchr && rsync -arv $smGlfParent $copyglf/$chrchr && $cmd && rm -rf $smGlfParentCopy";
            }
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            if ( $expandFlag == 1 ) {
                my $cptdir = "$outdir/cpt/glfs/$chrchr";
                my $cptMAKdir = $cptdir;
                $cptMAKdir =~ s/$outdir/\$(OUT_DIR)/g;
                my $newcmd = "$vcf.OK: $cptMAKdir/all.OK\n\tmkdir --p $vcfParent\n";
                if($sleepSecs != 0)
                {
                    $newcmd .= "\tsleep $sleepSecs\n";
                }
                $newcmd .= "\t".getMosixCmd($cmd, "$vcf")."\n\t".getTouch("$vcf")."\n";
                $newcmd =~ s/$outdir/\$(OUT_DIR)/g;
                push(@cmds,"$newcmd");
            }
            else {
                my $newcmd = "$vcf.OK:\n\tmkdir --p $vcfParent\n";
                if($sleepSecs != 0)
                {
                    $newcmd .= "\tsleep $sleepSecs\n";
                }
                $newcmd .= "\t".getMosixCmd($cmd, "$vcf")."\n\t".getTouch("$vcf")."\n";
                push(@cmds,"$newcmd");
            }
        }
        my $out = "$vcfDir/$chrchr/$chrchr.merged";
        print MAK "vcf$chr: $remotePrefix$out.vcf.OK\n\n";
        print MAK "$remotePrefix$out.vcf.OK: ";
        my $dep = join(".OK ",@vcfs);
        $dep =~ s/$outdir/\$(OUT_DIR)/g;
        print MAK $dep;
        print MAK ".OK\n";
        if ( $#uniqBeds < 0 ) {
            my $cmd = "\t".getConf("VCFMERGE")." $unitChunk @vcfs > $out.vcf 2> $out.log\n";
            $cmd =~ s/$outdir/\$(OUT_DIR)/g;
            $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
            print MAK "$cmd";
        }
        else {  ## targeted regions - rely on the loci info
            my $cmd = getConf("VCFCAT")." @vcfs > $out.vcf";
            writeLocalCmd($cmd);
        }
        print MAK "\tcut -f 1-8 $out.vcf > $out.sites.vcf\n";
        writeTouch("$out.vcf");
        print MAK join("\n",@cmds);
        print MAK "\n";
    }

    #############################################################################
    ## STEP 10-2 : SAMTOOLS PILEUP TO GENERATE GLF
    #############################################################################
    if ( getConf("RUN_PILEUP") eq "TRUE" ) {
        ## glf[$chr]: all-list-of-sample-glfs
        my @allSmGlfOKs = ();
        my @allcpts = ();
        my @sampleCmds = ();
        my $bamPileupCmds = "";
        my $idxDependency = "";
        if (getConf("RUN_INDEX") eq "TRUE") { $idxDependency = " bai"; }

        my $cptdir = "$outdir/cpt/glfs/$chrchr";
        my $cptMAKdir = $cptdir;
        $cptMAKdir =~ s/$outdir/\$(OUT_DIR)/g;
        system("mkdir -p $cptdir") && die "Unable to create directory '$cptdir'\n";

        # for each sample
        for(my $i=0; $i < @allSMs; ++$i) {
            my @bams = @{$hSM2bams{$allSMs[$i]}};
            my $cptOK = "$cptMAKdir/$allSMs[$i].OK";
            push(@allcpts,$cptOK);
            # for each partition of the genome.

            my $glfCmdHdr = "$cptOK:$idxDependency";
            my $glfCmdBody = "";

            for(my $j=0; $j < @unitStarts; ++$j)
            {
                # Set this region & loci information (if applicable) for doing the pileup(s).
                my $region = "$chr:$unitStarts[$j]-$unitEnds[$j]";
                my $loci = "";
                # Loci is only set if unique beds are used.
                if ( $#uniqBeds >= 0 ) {
                    my $idx = $hBedIndices{$allSMs[$i]};
                    $loci = "-l $targetDir/$uniqBedFns[$idx]/$chrchr/$chr.$unitStarts[$j].$unitEnds[$j].loci";
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

                my $smGlfPartitionDir = "$remotePrefix$smGlfDir/$chrchr/$unitStarts[$j].$unitEnds[$j]";
                my $smGlfFilename = "$allSMs[$i].$chr.$unitStarts[$j].$unitEnds[$j].glf";
                my $smGlf = "$smGlfPartitionDir/$smGlfFilename";

                push(@allSmGlfOKs,"$smGlf.OK") if ( $chunkOK );

                # Start the sample glf target
                my $sampleCmd = "$smGlf.OK:$idxDependency";

                #Check how many BAMs there are.
                if($#bams == 0)
                {
                    # There is just one BAM for this sample.
                    # Run pileup on this BAM and output as the sample GLF name.
                    if ( $chunkOK ) {
                        if (getConf("BAM_DEPEND") eq "TRUE") { $sampleCmd .= " $bams[0]"; }
                        $sampleCmd .= "\n\tmkdir --p $smGlfPartitionDir\n";
                        $sampleCmd .= logCatchFailure("pileup",
                                                      getMosixCmd(runPileup($bams[0], $smGlf, $region, $loci), $smGlf),
                                                      "$smGlf.log");
                    }
                    else {
                        if (getConf("BAM_DEPEND") eq "TRUE") { $glfCmdHdr .= " $bams[0]"; }
                        if($glfCmdBody ne "")
                        {
                            $glfCmdBody .= " && ";
                        }
                        $glfCmdBody .= "mkdir --p $smGlfPartitionDir && ";
                        $glfCmdBody .= runPileup($bams[0], $smGlf, $region, $loci);
                    }
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
                        my $bamGlf = "$remotePrefix$bamGlfDir/$allSMs[$i]/$chrchr/$bamFn.$unitStarts[$j].$unitEnds[$j].glf";
                        push(@bamGlfs,$bamGlf);

                        # Add the target info for this pileup.
                        if ( $chunkOK ) {
                            $bamPileupCmds .= "$bamGlf.OK:$idxDependency";
                            if (getConf("BAM_DEPEND") eq "TRUE") { $bamPileupCmds .= " $bam"; }
                            $bamPileupCmds .= "\n\tmkdir --p $bamGlfDir/$allSMs[$i]/$chrchr\n";
                            $bamPileupCmds .= logCatchFailure("pileup",
                                                              getMosixCmd(runPileup($bam, $bamGlf, $region, $loci), $bamGlf),
                                                              "$bamGlf.log");
                            $bamPileupCmds .= "\t".getTouch("$bamGlf")."\n\n";
                        }
                        else {
                            if (getConf("BAM_DEPEND") eq "TRUE") { $glfCmdHdr .= " $bam"; }
                            if($glfCmdBody ne "")
                            {
                                $glfCmdBody .= " && ";
                            }
                            $glfCmdBody .= "mkdir --p $bamGlfDir/$allSMs[$i]/$chrchr && ";
                            $glfCmdBody .= runPileup($bam, $bamGlf, $region, $loci);
                        }
                    }
                    # Add the BAM specific GLFs to the sample glf dependency.
                    if ( $chunkOK ) {
                        $sampleCmd .= " ".join(".OK ",@bamGlfs).".OK\n";
                        $sampleCmd .= "\tmkdir --p $smGlfPartitionDir\n";
                    }
                    else {
                        if($glfCmdBody ne "")
                        {
                            $glfCmdBody .= " && ";
                        }
                        $glfCmdBody .= "mkdir --p $smGlfPartitionDir";
                    }

                    my $qualities = "0";
                    my $minDepths = "1";
                    my $maxDepths = "1000";
                    for(my $k=1; $k < @bamGlfs; ++$k) {
                        $qualities .= ",0";
                        $minDepths .= ",1";
                        $maxDepths .= ",1000";
                    }

                    # Merge the multiple GLFs for this sample.
                    if ( $chunkOK ) {
                        $sampleCmd .= "\t".getMosixCmd(getConf("GLFMERGE")." --qualities $qualities --minDepths $minDepths --maxDepths $maxDepths --outfile $smGlf @bamGlfs > $smGlf.out 2>&1", "$smGlf")."\n";
                        $sampleCmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                    }
                    else {
                        if($glfCmdBody ne "")
                        {
                            $glfCmdBody .= " && ";
                        }
                        $glfCmdBody .= getConf("GLFMERGE")." --qualities $qualities --minDepths $minDepths --maxDepths $maxDepths --outfile $smGlf @bamGlfs > $smGlf.out 2>&1";
                    }
                }
                if ( $chunkOK ) {
                    $sampleCmd .= "\t".getTouch("$smGlf")."\n";
                    push(@sampleCmds,$sampleCmd);
                }
            }
            unless ( $chunkOK ) {
                $glfCmdHdr  =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                $glfCmdBody =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
                push(@sampleCmds,$glfCmdHdr);
                push(@sampleCmds, "\t".getMosixCmd($glfCmdBody, $cptOK));
                push(@sampleCmds, "\ttouch $cptOK\n");
            }
        }

        print MAK "glf$chr: $cptMAKdir/all.OK\n\n";
        print MAK "$cptMAKdir/all.OK: ";
        if ( $chunkOK ) {
            print MAK join(" ",@allSmGlfOKs);
        }
        else {
            print MAK join(" ",@allcpts);
        }
        print MAK "\n\ttouch $cptMAKdir/all.OK\n\n";

        # Add the per sample commands
        print MAK join("\n",@sampleCmds);
        print MAK "\n";
        # Add the per BAM pileup commands
        print MAK "$bamPileupCmds" if ( $chunkOK );
    }
}

print MAK "\nclean:\n";
for(my $i=0; $i < @toClean; ++$i) {
    print MAK "\trm -rf $toClean[$i]\n";
}
if ( getConf("RUN_VCFPILEUP") eq "TRUE" )
{
    print MAK "\trm -rf $pvcfDir\n";
}


#############################################################################
## Check for WGS_SVM and handle that
############################################################################
if ( getConf("WGS_SVM") eq "TRUE")
{
    if( (scalar @wgsFilterDepSites) > 0 )
    {
        print MAK "$remotePrefix$vcfDir/${svmPrefix}filtered.vcf.gz.OK:$wgsFilterDepVcfs\n";

        my $mergedSites = "$remotePrefix$vcfDir/${filterPrefix}filtered.sites.vcf";
        my $outMergedVcf = "$remotePrefix$vcfDir/${svmPrefix}filtered.sites.vcf";

        # Add the vcf header.
        writeLocalCmd(getConf("VCFCAT")." @wgsFilterDepSites > $mergedSites");

        # Run SVM on the merged file.
        runSVM($mergedSites, $outMergedVcf);

        # split svm file by chromosome.
        writeLocalCmd(getConf("VCF_SPLIT_CHROM")." --in $outMergedVcf --out $remotePrefix$vcfDir/chrCHR/chrCHR.${svmPrefix}filtered.sites.vcf --chrKey CHR");
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
        print MAK "\n\t".getMosixCmd($cmd, "$bam.bai")."\n\t".getTouch("$bam.bai")."\n\n";
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
#      * it is older than the bam list file
#--------------------------------------------------------------
sub handleGlfIndexFile
{
    my ($smGlfParentCopy, $smGlfParent, $vcfParent, $chr, $unitStart, $unitEnd) = @_;

    # Ensure the path exists.
    make_path($vcfParent);

    my $glfIndexFile = "$vcfParent/".getConf("GLF_INDEX");
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
            #    2) the glfIndexFile is newer than the bamList
            if( ($expectedLine eq $firstLine) && ( -M "$bamList" >= -M "$glfIndexFile" ) )
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
        $cmd = getConf("SVM_SCRIPT")." --invcf $inVcf --out $outVcf --model ".getConf("SVMMODEL")." --svmlearn ".getConf("SVMLEARN")." --svmclassify ".getConf("SVMCLASSIFY")." --bin ".getConf("INVNORM")." --threshold ".getConf("SVM_CUTOFF")." --bfile ".getConf("OMNI_VCF")." --bfile ".getConf("HM3_VCF")." --checkNA > $outVcf.out 2>&1";
    }
    else
    {
        $cmd = getConf("SVM_SCRIPT")." --invcf $inVcf --out $outVcf --pos ".getConf("POS_SAMPLE")." --neg ".getConf("NEG_SAMPLE")." --svmlearn ".getConf("SVMLEARN")." --svmclassify ".getConf("SVMCLASSIFY")." --bin ".getConf("INVNORM")." --threshold ".getConf("SVM_CUTOFF")." --bfile ".getConf("OMNI_VCF")." --bfile ".getConf("HM3_VCF")." --checkNA > $outVcf.out 2>&1";
    }

    $cmd =~ s/$gotcloudRoot/\$(GOTCLOUD_ROOT)/g;
    print MAK "\t".getMosixCmd($cmd, "$outVcf")."\n";
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

    my $md5Dir = "";
    if(exists $isCram{$bamIn})
    {
        $md5Dir = "REF_PATH=".getConf("MD5_DIR")." ";
    }

    return("($md5Dir".getConf("SAMTOOLS_FOR_OTHERS")." view ".getConf("SAMTOOLS_VIEW_FILTER")." -uh $bamIn $region |$baq ".getConf("BAMUTIL",1)." clipOverlap --in -.ubam --out -.ubam ".getConf("BAMUTIL_THINNING")." | ".getConf("SAMTOOLS_FOR_PILEUP")." pileup -f $ref $loci -g - > $glfOut) 2> $glfOut.log");
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
    open(IN,$bed) || die "Cannot open bed file: $bed\n";
    while(<IN>) {
        my ($chr,$start,$end) = split;

        if(!defined($hChrSizes{$chr}))
        {
            if($chr =~ /^chr/)
            {
                my $tmpChr = $chr;
                $tmpChr =~ s/^chr//;
                if(!defined($hChrSizes{$tmpChr}))
                {
                    warn "BED, $bed, chromosome, $chr, not found in the reference file, so will not be processed.\n";
                }
                else
                {
                    $chr = $tmpChr;
                }
            }
            else
            {
                if(!defined($hChrSizes{"chr".$chr}))
                {
                    warn "BED, $bed, chromosome, $chr, not found in the reference file, so will not be processed.\n";
                }
                else
                {
                    $chr = "chr$chr";
                }
            }
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
    my ($cmd, $cmdKey) = @_;

    my $logOption = "";
    if(defined ($cmdKey) && $cmdKey)
    {
        $logOption = "-log $makef_OUT_DIR.cluster,$cmdKey ";
    }

    $cmd =~ s/'/"/g;            # Avoid issues with single quotes in command
    my $newcmd = $runcluster.' -bashdir $(OUT_DIR)/jobfiles '.${logOption};
    if($batchopts)
    {
        $newcmd .= "-opts '".$batchopts."' ";
    }
    $newcmd .= "$batchtype '$cmd'";
    return $newcmd;
}

#############################################################################
## writeLocalCmd() : Write a local command to the makefile
## This should be used for short commands that can be executed on the local machine
############################################################################
sub writeLocalCmd {
    my $cmd = shift;

    # Replace gotcloudRoot with a Makefile variable.
    $cmd =~ s/$outdir/\$(OUT_DIR)/g;
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
#   cmd = getTouch(okBase, outputFile)
#
#   return the touch command, appending .OK to the output file.
#--------------------------------------------------------------
sub getTouch {
    my ($okBase, $outputFile) = @_;

    $okBase =~ s/\.OK$//;

    if(! defined ($outputFile)) { $outputFile = $okBase; $outputFile =~ s/\.OK$//;}

    #return("if [ -e  $outputFile ]; then touch $okBase.OK; else exit 1; fi");
    # Give NFS several chances to catch up
    # Note: the return status of a for loop or conditional is the return status of the last command run.
    return("for i in 1 2 3 4 5 6; do if [ -e $outputFile ]; then touch $okBase.OK; break; else sleep 10; false; fi; done || exit 17;");
}


#--------------------------------------------------------------
#   cmd = writeTouch(okBase, outputFile)
#
#   write the touch command to the makefile appending .OK to the output file.
#--------------------------------------------------------------
sub writeTouch {
    my ($okBase, $outputFile) = @_;

    if(! defined ($outputFile)) { $outputFile = $okBase; $outputFile =~ s/\.OK$//; }

    print MAK "\t".getTouch($okBase, $outputFile)."\n\n";
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
  BAM_LIST = listFile.txt
  # References
  REF_ROOT = $(TEST_ROOT)/ref
  REF = $(REF_ROOT)/karma.ref/human.g1k.v37.chr20.fa
  INDEL_PREFIX = $(REF_ROOT)/indels/1kg.pilot_release.merged.indels.sites.hg19
  DBSNP_VCF =  $(REF_ROOT)/dbSNP/dbsnp135_chr20.vcf.gz
  HM3_VCF =  $(REF_ROOT)/HapMap3/hapmap_3.3.b37.sites.chr20.vcf.gz

The B<bam list> file specifies information about individuals and paths to
bam data. The data is tab delimited.

=head1 OPTIONS

=over 4

=item B<--conf file>

Specifies the configuration file to be used.
The default configuration is B<gotcloudDefaults.conf> found in the same directory
where this program resides.
If this file is not found, you must specify this option on the command line.

=item B<--list str>

Specifies the name of the file containing the table of bams to process.
This value must be set in the configuration file or specified by this option.

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

=item B<--beagle>

Run the beagle set of steps (beagle and subset).

=item B<--thunder>

Run thunder.

=item B<--beagle4>

Run the beagle4 step.

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

=item B<--split4>

Run as if just RUN_SPLIT4 was specified.

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

=item B<--ref_dir dir>

Specifies the location of the reference files, overriding the configuration
value of REF_DIR.

=item B<--ref_prefix dir>

This specifies a directory prefix which should be added to relative reference file paths.

=item B<--bam_prefix dir>

This specifies a directory prefix which should be added to relative paths in the bam list file.

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

