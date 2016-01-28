#!/usr/bin/env perl
#################################################################
#
# Name: align.pl
#
# Description:
#   Use this to generate makefiles for a single session whatever it is.
#
#   You can run this program using the test data by the following:
#       rm -rf ~/outdata
#       d=/gotcloud/test/align
#       /gotcloud/bin/align.pl -conf $d/test.conf \
#          -index_file $d/indexFile.txt -ref_dir $d/../chr20Ref/ \
#          -fastq_prefix $d   -out ~/outdata
#
#   You can verify the results on the test data are expected using:
#       /gotcloud/scripts/diff_results_align.sh ~/outdata $d/expected
#
#   This set of steps is the equivalent of doing  '/gotcloud/bin/align.pl -test ~/outdata'
#
# Todo:
#   Rewrite conf handling to use a hash, rather than a mess of separate variables
#   purge GOTCLOUD_ROOT from use
#   Clean up parse of indexfile
#   Clean up creation of Makefile
#   FLUX and such engines will not work until we add batch dependencies
#   Allow for fastq input file to have comment or blank lines
#
# ChangeLog:
#   13 Aug 2012 tpg   Initial coding
#   18 Oct 2012 mkt   Update to use index
#   22 Jan 2013 tpg   Execute the make commands
#   12 Feb 2013 tpg   Conf file clean up. Comments, defaults, required
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################
use strict;
use warnings;
use Getopt::Long;
use IO::Zlib;
use File::Basename;
use Cwd;
use Cwd 'abs_path';

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
my $GCURL = 'http://genome.sph.umich.edu/wiki/GotCloud:_Genetic_Reference_and_Resource_Files';

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
    override => '',
);
Getopt::Long::GetOptions( \%opts,qw(
    help
    dry-run|dryrun
    batchtype=s
    batchopts=s
    test=s
    out_dir|outdir=s
    conf=s
    list|fastq_list|fastqlist|index|index_file|indexfile=s
    ref_dir|refdir=s
    ref_prefix|refprefix=s
    fastq_prefix|fastqprefix=s
    base_prefix|baseprefix=s
    keeptmp
    keeplog
    cram
    noPhoneHome
    verbose=i
    threads=i
    numjobs=i
    numcs=i
    maxlocaljobs=i
    override=s
    gotcloudroot|gcroot=s
)) || die "Failed to parse options\n";

if ($opts{numcs})
{
    die "ERROR: The '--numcs' option has been removed, please use:\n\t--numjobs : number of samples to run concurrently (previously '--numcs').\n\t--threads : number of jobs per sample (previously '--numjobs').\n";
}

#   Simple help if requested, sanity check input options
if ($opts{help}) {
    warn "$me$mesuffix [options]\n" .
        "Use this to generate makefiles for a single session whatever it is.\n" .
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

my @confSettings;
push(@confSettings, "GOTCLOUD_ROOT = $gotcloudRoot");

#--------------------------------------------------------------
#   Check if we are running the test case.
#--------------------------------------------------------------
#   Special case for convenient testing
if ($opts {test}) {
    # remove any trailing slashes.
    $opts{test} =~ s/\/+\z//;
    my $outdir=abs_path($opts{test});
    die "Parent directory of $opts{test} should exist." if ! defined($outdir);
    system("mkdir -p $outdir") &&
        die "Unable to create directory '$outdir'\n";
    my $testoutdir = $outdir . '/aligntest';
    print "Removing any previous results from: $testoutdir\n";
    system("rm -rf $testoutdir") &&
        die "Unable to clear the test output directory '$testoutdir'\n";
    print "Running GOTCLOUD TEST, test log in: $testoutdir.log\n";
    my $testdir = $gotcloudRoot . '/test/align';
    if(! -r $testdir)
    {
        die "ERROR, '$testdir' does not exist, please download the test data to that directory\n";
    }
    my $cmd = "$0 -conf $testdir/test.conf -out $testoutdir";
    if($opts{gotcloudroot})
    {
        $cmd .= " --gotcloudRoot $gotcloudRoot";
    }
    system($cmd) &&
        die "Failed to generate test data. Not a good thing.\nCMD=$cmd\n";
    $cmd = "$gotcloudRoot/scripts/diff_results_align.sh $outdir $gotcloudRoot/test/align/expected";
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


# Conf file no longer required.
if ($opts{conf})
{
    $opts{conf} = abs_path($opts{conf});
}

#############################################################################
#   Set configuration variables from comand line options
#############################################################################
if ($opts{out_dir}) {
    # remove any trailing slashes.
    $opts{out_dir} =~ s/\/+\z//;
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
if ($opts{fastq_prefix}) { push(@confSettings, "FASTQ_PREFIX = $opts{fastq_prefix}"); }
if ($opts{base_prefix})  { push(@confSettings, "BASE_PREFIX = $opts{base_prefix}"); }
if ($opts{keeptmp})      { push(@confSettings, "KEEP_TMP = $opts{keeptmp}"); }
if ($opts{keeplog})      { push(@confSettings, "KEEP_LOG = $opts{keeplog}"); }
if (exists $opts{cram})  { push(@confSettings, "ALIGN_CRAM_OUTPUT = TRUE"); }
if ($opts{list})         { push(@confSettings, "FASTQ_LIST = $opts{list}"); }
if ($opts{batchtype})    { push(@confSettings, "BATCH_TYPE = $opts{batchtype}"); }
if ($opts{batchopts})    { push(@confSettings, "BATCH_OPTS = $opts{batchopts}"); }

# Process the override flags.
push(@confSettings, split(";", $opts{override}));

#############################################################################
#   Load configuration variables from conf file
#   Load config values. The default conf file is almost never seen by the user,
push(@configs, $opts{pipelinedefaults});

if (loadConf(\@confSettings, \@configs, $opts{verbose})) {
    die "Failed to read configuration files\n";
}

my @perMergeStep = split(' ', getConf("PER_MERGE_STEPS"));
my @cramSteps = split(' ', getConf("ALIGN_CRAM_OUTPUT_STEPS"));
my @allSteps = @perMergeStep;
if(uc(getConf("ALIGN_CRAM_OUTPUT")) eq "TRUE")
{
    push(@allSteps, @cramSteps);
}


if(!getConf("FASTQ_LIST"))
{
    if(getConf("INDEX_FILE"))
    {
        setConf("FASTQ_LIST", getConf("INDEX_FILE"));
    }
}

#############################################################################
#   Make sure paths for variables are fully qualified
#############################################################################
# Do not add FASTQ_PREFIX to FASTQ_LIST. FASTQ_PREFIX is the prefix to add
# to the fastq file names.
foreach my $key (qw(REF_DIR OUT_DIR)) {
    my $f = getConf($key);
    if (! $f) { die "Required field $key was not specified\n"; }
    #   Extract up to the first '_' from the key to get the prefix type option.
    my $type = substr($key, 0, index($key, '_'));
    #   Replace the already stored value with the absolute path
    setConf($key, getAbsPath($f, $type));
}

# paths to add base prefix, but not specific type.
foreach my $key (qw(FASTQ_LIST)) {
    my $f = getConf($key);
    if (! $f) { die "Required field $key was not specified\n"; }
    #   Replace the already stored value with the absolute path
    setConf($key, getAbsPath($f));
}
my $index_file = getConf('FASTQ_LIST');
my $out_dir = getConf('OUT_DIR');

#----------------------------------------------------------------------------
#   Check required settings
#----------------------------------------------------------------------------
my $missingReqFile = 0;
#   These files must exist
my @reqRefs = qw(REF DBSNP_VCF);

# Loop through the defined steps & check for required exes.
foreach my $step (@perMergeStep)
{
    if($step eq "verifyBamID")
    {
        push(@reqRefs, "HM3_VCF");
    }
}

foreach my $f (@reqRefs)
{
    # Replace the path with the absolute path
    my $newPath = getAbsPath(getConf($f), 'REF');
    setConf($f, $newPath);
    # Check that the path exists.
    if (-r $newPath) { next; }
    warn "ERROR: Could not read required $f: $newPath\n";
    $missingReqFile++;
}

foreach my $step (@perMergeStep)
{
    if($step eq "qplot")
    {
        $missingReqFile += CheckFor_REF_File('.winsize100.gc', 1);
    }
}

#   Check for the required sub REF files.
my @mapExtensions;
my $removeExt = 0;
my $oneBwa = 0;
my $prevBwa = "";

# Ensure the map type is in all caps.
setConf('MAP_TYPE', uc(getConf('MAP_TYPE')));

if ( (getConf('MAP_TYPE') eq 'BWA') || (getConf('MAP_TYPE') eq 'BWA_MEM') ) {
    @mapExtensions = qw(.amb .ann .bwt .pac .sa);
    if(defined getConf("ONE_BWA") && getConf("ONE_BWA") ne 0 && getConf("ONE_BWA") ne "")
    {
        $oneBwa = 1;
    }
}
elsif (getConf('MAP_TYPE') eq 'MOSAIK') {
    @mapExtensions = qw(.dat _15_keys.jmp _15_meta.jmp _15_positions.jmp);
    $removeExt = 1;
    # Check for ANN files
    if(! -r getConf("SE_ANN"))
    {
        warn "ERROR: Could not read required SE_ANN: ".getConf("SE_ANN")."\n";
            warn "See ${GCURL} for information about building this file\n";
            $missingReqFile = "1";
    }
    if(! -r getConf("PE_ANN"))
    {
        warn "ERROR: Could not read required PE_ANN: ".getConf("PE_ANN")."\n";
            warn "See ${GCURL} for information about building this file\n";
            $missingReqFile = "1";
    }
}
else
{
    warn "ERROR: Unknown MAP_TYPE, '" . getConf('MAP_TYPE') . "', only BWA or MOSAIK is accepted.\n";
    $missingReqFile++;
}

#   Check for the reference files
for my $extension (@mapExtensions) {
    $missingReqFile += CheckFor_REF_File($extension, $removeExt);
}

# Always require fai file.
$missingReqFile += CheckFor_REF_File(".fai", 0);

if ($missingReqFile) { die "Exiting alignment pipeline due to required file(s) missing\n"; }


#----------------------------------------------------------------------------
# Check for consistancy in chromosome naming.
#----------------------------------------------------------------------------
# Read names from REF.fai file.
my $faiFile = getConf('REF').".fai";
open(FAI, $faiFile) || die "ERROR: Cannot open file $faiFile: $!\n";
my %faiChrs;
while(<FAI>)
{
    my ($chr) = split(/[\t\n]+/);
    $faiChrs{$chr} = 1;
}
close(FAI);

# Check the VCFs for mathcing chromosomes in the .fai file.
for my $refType (@reqRefs)
{
    my $refVcf = getConf($refType);
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
        if(!exists $faiChrs{$chr})
        {
            my $newChr = "chr$chr";
            if(exists $faiChrs{$newChr})
            {
                die "ERROR: $refTbi has $chr, but $faiFile has $newChr.  Chromosome names must be consistent.\n";
            }
            $newChr = $chr;
            $newChr =~ s/^chr//;
            if(exists $faiChrs{$newChr})
            {
                die "ERROR: $refTbi has $chr, but $faiFile has $newChr.  Chromosome names must be consistent.\n";
            }
            warn "WARNING: $chr found in $refTbi is not in found in $faiFile\n";
        }
    }
    close(REFTBI);
}


#----------------------------------------------------------------------------
#   Check for required executables
#----------------------------------------------------------------------------
my @reqExes = qw(SAMTOOLS_SORT_EXE SAMTOOLS_EXE BAM_EXE);
if ( (getConf('MAP_TYPE') eq 'BWA') || (getConf('MAP_TYPE') eq 'BWA_MEM') )
{
    push(@reqExes, 'BWA_EXE');
}
elsif (getConf('MAP_TYPE') eq 'MOSAIK')
{
    push(@reqExes, 'MOSAIK_ALIGN_EXE');
    push(@reqExes, 'MOSAIK_BUILD_EXE');
}
my $missingExe = 0;
foreach my $exe (@reqExes)
{
    if(-x getConf($exe)) { next; }
    print "$exe, ".getConf($exe)." is not executable\n";
    $missingExe++;
}
# Loop through the defined steps & check for required exes.
foreach my $step (@allSteps)
{
    my $exes = getConf($step."_REQ_EXES");
    if(defined $exes)
    {
        # split if multiple EXEs.
        my @exesArray = split(/\s+/, $exes);
        foreach my $exe (@exesArray)
        {
            if(-x $exe) { next; }
            print $step."_REQ_EXES, ".$exe." is not executable\n";
            $missingExe++;
        }
    }
}

if($missingExe)
{
    die "EXITING: Missing required exes.  Try typing 'make' in the gotcloud/src directory\n";
}

#----------------------------------------------------------------------------
#   Check for deprecated required settings
#----------------------------------------------------------------------------

# Deprecated settings and their replacements:
my %deprecated = (
    FA_REF => "REF",
    FASTQ => "FASTQ_PREFIX",
    BWA_MAX_MEM => "SORT_MAX_MEM",
    VERIFY_BAM_ID_OPTIONS => "verifyBamID_USER_PARAMS",
    MORE_RECAB_PARAMS => "recab_USER_PARAMS",
    ALT_RECAB => "recab_CMD",
    ALT_DEDUP => "dedup_CMD",
    RUN_QPLOT => "PER_MERGE_STEPS",
    RUN_VERIFY_BAM_ID => "PER_MERGE_STEPS",
);

my $deprecatedFiles = 0;
foreach my $key (keys %deprecated )
{
    if(getConf("$key"))
    {
        warn "ERROR: '$key' is deprecated and has been replaced by '$deprecated{$key}'\n";
        $deprecatedFiles++;
    }
}

if($deprecatedFiles)
{
    die "EXITING: Deprecated configuration.  Please update your configyration and rerun.\n";
}

# Just warn about these deprecated values.
my %deprecatedWarn = (
    BAM_INDEX => "BAM_LIST",
    INDEX_FILE => "FASTQ_LIST",
    FASTQ => "FASTQ_PREFIX",
    BWA_MAX_MEM => "SORT_MAX_MEM",
    VERIFY_BAM_ID_OPTIONS => "verifyBamID_USER_PARAMS",
    MORE_RECAB_PARAMS => "recab_USER_PARAMS",
    ALT_RECAB => "recab_CMD",
    ALT_DEDUP => "dedup_CMD",
    RUN_QPLOT => "PER_MERGE_STEPS",
    RUN_VERIFY_BAM_ID => "PER_MERGE_STEPS",
);

foreach my $key (keys %deprecatedWarn)
{
    if(getConf("$key"))
    {
        warn "WARNING: '$key' is deprecated and has been replaced by '$deprecatedWarn{$key}'\n";
    }
}

#----------------------------------------------------------------------------
#   Check for valid parameters
#----------------------------------------------------------------------------
if (getConf('MAP_TYPE') eq 'BWA')
{
    # Validate BWA_THREADS & BWA_QUAL.
#    my $option = "-[oeidlkmMOERqB] +[0-9]+|-[LNIY]|-n +[0-9]*.?[0-9]+";
#    if(getConf("BWA_QUAL") !~ /^((${option}) +)*-q +[0-9]+( +(${option}))*$/)
    if(getConf("BWA_QUAL") !~ /^(.* )*-q +[0-9]+( .*)*$/)
    {
        die "ERROR: BWA_QUAL is invalid.  Be sure you specified '-q trimQual', ".getConf("BWA_QUAL")."\n";
    }
#    if(getConf("BWA_THREADS") !~ /^((${option}) +)*-t +[0-9]+( +(${option}))*$/)
    if(getConf("BWA_THREADS") !~ /^(.* )*-t +[0-9]+( .*)*$/)
    {
        die "ERROR: BWA_THREADS is invalid.  Be sure you specified '-t #threads', ".getConf("BWA_THREADS")."\n";
    }
}
elsif(getConf('MAP_TYPE') eq 'BWA_MEM')
{
    # Validate BWA_THREADS
    if(getConf("BWA_THREADS") !~ /^(.* )*-t +[0-9]+( .*)*$/)
    {
        die "ERROR: BWA_THREADS is invalid.  Be sure you specified '-t #threads', ".getConf("BWA_THREADS")."\n";
    }
}

#----------------------------------------------------------------------------
#   Perform phone home and check storage requirements.
#----------------------------------------------------------------------------
# Check if fastq_prefix is specified.
my $fastqpref = getConf('FASTQ_PREFIX');
if( !$fastqpref )
{
    # FASTQ_PREFIX is not set, so use BASE_PREFIX.
    $fastqpref = getConf('BASE_PREFIX');
}

if (! $opts{'dry-run'}) {
    #   All set now, phone home to check for a new version. We don't care about failures.
    if(!$opts{noPhoneHome})
    {
        system($opts{phonehome});
    }
    else
    {
        setConf("BAMUTIL_THINNING", "--phoneHomeThinning 0");
    }
    #   Last warning to user about storage requirements
    system($opts{calcstorage} . ' ' . getConf('FASTQ_LIST') . ' ' . $fastqpref);
}


#----------------------------------------------------------------------------
#   Output the configuration settings.
#----------------------------------------------------------------------------
system("mkdir -p $out_dir/Makefiles") &&
    die "Unable to create directory '$out_dir/Makefiles'\n";
dumpConf("$out_dir/Makefiles/align.conf");

#############################################################################
#   Read the Index File
#############################################################################
open(IN,$index_file) ||
    die "Unable to open index_file '$index_file': $!\n";

#   Read the first line and check if it is a header or a reference
my $line = <IN>;
chomp($line);
my $numSubs = 0;
$numSubs = $line =~ s/^\s+|\s+$//g;
my $numHdrWarn = 0;
if(($numSubs > 0) || ($line =~ m/ \t|\t /))
{
    print "\nWarning: Removed spaces from the header fields of ${index_file}\n";
    ++$numHdrWarn;
}

#   Track positions for each field
my @fieldnames = qw(MERGE_NAME FASTQ1 FASTQ2 RGID SAMPLE LIBRARY CENTER PLATFORM RG);
my %fieldname2index = ();
foreach my $key (@fieldnames) { $fieldname2index{$key} = undef(); } # Avoid tedious hardcoding
# There are no spaces in the field names, so split on spaces.
my @fields = split(/\s+/, $line);

# If spaces were used instead of a tab between header fields, warn.
if($line =~ m/[^\t ] +[^ \t]/)
{
    print "\nWarning: treating spaces as tabs in the header fields of ${index_file}\n";
    ++$numHdrWarn;
}

# If there were two consecutive tabs between header fields, warn.
if($line =~ m/\t\t/)
{
    print "\nWarning: ignoring extra tabs in the header fields of ${index_file}\n";
    ++$numHdrWarn;
}

my $numHeaderFields = scalar @fields;
foreach my $index (0..$#fields)
{
    my $field = uc($fields[$index]);
    if (! exists($fieldname2index{$field})) { warn "Warning, ignoring unknown header field, $field\n"; next; }
    $fieldname2index{$field} = $index;
}
foreach my $key (qw(FASTQ1)) {       # These are required, other columns could be missing
    if (! defined($fieldname2index{$key})) { die "ERROR: Index File, $index_file, is missing required header field, $key\n"; }
}

# Either MERGE_NAME or SAMPLE are required.
if(! defined($fieldname2index{MERGE_NAME}))
{
    if(! defined($fieldname2index{SAMPLE}))
    {
        die "ERROR: Index File, $index_file, is missing required header field.  Either 'MERGE_NAME' or 'SAMPLE' is required.\n";
    }
    else
    {
        $fieldname2index{MERGE_NAME} = $fieldname2index{SAMPLE};
    }
}

# if RG is specified:
#    1) it must be the last field
#    2) RGID, LIBRARY, CENTER, and PLATFORM must not be specified
if(defined($fieldname2index{RG}))
{
    if($fieldname2index{RG} != $#fields)
    {
        die "ERROR: RG must be the last field in $index_file\n";
    }
    if(defined($fieldname2index{RGID}) || defined($fieldname2index{SAMPLE}) || defined($fieldname2index{LIBRARY}) ||
       defined($fieldname2index{CENTER}) || defined($fieldname2index{PLATFORM}))
    {
        die "ERROR: in $index_file, if RG is specified, RGID, LIBRARY, CENTER, and PLATFORM can't be specified.\n";
    }
}




#----------------------------------------------------------------------------
#   Read the rest of the file
#----------------------------------------------------------------------------
my %fq1toFq2 = ();
my %fq1toRGID = ();
my %fq1toSm = ();
my %fq1toLib = ();
my %fq1toCn = ();
my %fq1toPl = ();
my %fq1toRG = ();
my %mergeToFq1 = ();
my %smToMerge = ();
my $numBlanks = 0;
my $numFieldSubs = 0;
my $numMultiTab = 0;
my $numInfer = 0;
my $rgNum = 0;
my %warn = ();
while ($line = <IN>)
{
    chomp($line);
    $line =~ s/^\s+|\s+$//g;
    @fields = split(/\t\s*/, $line);

    if(scalar @fields == 0)
    {
        ++$numBlanks;
        next;
    }
    if($line =~ m/\t\s+|\s+\t/)
    {
        ++$numFieldSubs;
    }
    if($line =~ m/\t\t/)
    {
        ++$numMultiTab;
    }

    # Remove leading/trailing spaces from each field.
    foreach my $field (@fields)
    {
        $field =~ s/^\s+|\s+$//g;
    }
    # Check for number of fields if RG is not specified.
    if(!defined($fieldname2index{RG}) && ($numHeaderFields != scalar @fields))
    {
        die "\nERROR, incorrect number of fields in $index_file, ".scalar @fields.
        " fields instead of the $numHeaderFields fields found in the header line:\n\t".
        join("\n\t",@fields).
        "\nRemember, tabs are the delimiter and leading/trailing white spaces are trimmed\n\n";
    }
    # If RG is specified, verify the value at the RG index is @RG.
    if(defined($fieldname2index{RG}) && ($fields[$fieldname2index{RG}] ne "\@RG"))
    {
        die "\nERROR: \"\@RG\" is not in the \"RG\" column of $index_file\n".
        "$fields[$fieldname2index{RG}] was found instead.\n";
    }

    my $fastq1 = $fields[$fieldname2index{FASTQ1}];
    my $mergeName = $fields[$fieldname2index{MERGE_NAME}];
    if($mergeName eq '.')
    {
        # If merge name is not set, check the sample.
        if (defined($fieldname2index{SAMPLE}))
        {
            $mergeName = $fields[$fieldname2index{SAMPLE}];
        }
        if($mergeName eq '.')
        {
            die "\nERROR: It is invalid to have a '.' in both the 'MERGE_NAME' and 'SAMPLE' fields of $index_file.\n";
        }
    }
    push @{$mergeToFq1{$mergeName}}, $fastq1;

    if (defined($fieldname2index{FASTQ2}))   { $fq1toFq2{$fastq1} = $fields[$fieldname2index{FASTQ2}]; }
    else { $fq1toFq2{$fastq1} = '.'; }

    if(!defined($fieldname2index{RG}))
    {
        # whole RG line wasn't specified, so check for each field.
        if (defined($fieldname2index{RGID}))     { $fq1toRGID{$fastq1} = $fields[$fieldname2index{RGID}]; }
        else
        {
            # RG not in header.
            # Read the first line of the FASTQ to try to determine the RG
            my $fullPathFQ1 = getAbsPath($fastq1, 'FASTQ');
            die "ERROR: Cannot open file $fastq1: $!\n" unless ( -s $fullPathFQ1 );
            tie *FQ1, "IO::Zlib", $fullPathFQ1, "rb";
            my $fqline = FQ1->getline();
            close(FQ1);
            # Check if first line of fastq1 matches expected default format:
            if($fqline =~ m/^@([^:]*:[^:]*:[^:]*:[^:]*)/)
            {
                if(!exists $warn{RGID1})
                {
                    ++$numInfer;
                    warn "WARNING: RGID was not specified, so defaulting to the first 4 fields (':' delimited) of the first FASTQ1 sequence identifier.\n";
                    $warn{RGID1} = 1;
                }
                $fq1toRGID{$fastq1} = $1;
            }
            else
            {
                # Unable to determine readgroup, default to fastq name.
                if(!exists $warn{RGID2})
                {
                    ++$numInfer;
                    warn "WARNING: RGID was not specified, so defaulting to incrementing numbers.\n";
                    $warn{RGID2} = 1;
                }
                $fq1toRGID{$fastq1} = $rgNum++;
            }
        }

        if (defined($fieldname2index{SAMPLE}))   { $fq1toSm{$fastq1} = $fields[$fieldname2index{SAMPLE}]; }
        else { $fq1toSm{$fastq1} = $mergeName; }

        if (defined($fieldname2index{LIBRARY}))  { $fq1toLib{$fastq1} = $fields[$fieldname2index{LIBRARY}]; }
        else
        {
            if(!exists $warn{LIBRARY})
            {
                ++$numInfer;
                warn "WARNING: LIBRARY was not specified, so defaulting to the value of SAMPLE.\n";
                $warn{LIBRARY} = 1;
            }
            $fq1toLib{$fastq1} = $fq1toSm{$fastq1};
        }

        if (defined($fieldname2index{CENTER}))   { $fq1toCn{$fastq1} = $fields[$fieldname2index{CENTER}]; }
        else
        {
            if(!exists $warn{CENTER})
            {
                ++$numInfer;
                warn "WARNING: CENTER was not specified, so defaulting to 'unknown'.\n";
                $warn{CENTER} = 1;
            }
            $fq1toCn{$fastq1} = 'unknown';
        }

        if (defined($fieldname2index{PLATFORM})) { $fq1toPl{$fastq1} = $fields[$fieldname2index{PLATFORM}]; }
        else
        {
            if(!exists $warn{PLATFORM})
            {
                ++$numInfer;
                warn "WARNING: PLATFORM was not specified, so defaulting to 'ILLUMINA'.\n";
                $warn{PLATFORM} = 1;
            }
            $fq1toPl{$fastq1} = 'ILLUMINA';
        }
    }
    else
    {
        # Use RG line
        $fq1toRG{$fastq1} = "\"".join('\t',@fields[$fieldname2index{RG}..$#fields])."\"";
        # Set other values.
        if($fq1toRG{$fastq1} =~ /SM:([^\\"]*)/)
        {
            $fq1toSm{$fastq1} = $1;
        }
        else
        {
            $fq1toSm{$fastq1} = $mergeName;
        }
        if($fq1toRG{$fastq1} =~ /ID:([^\t ]*)/)
        {
            $fq1toRGID{$fastq1} = $1;
        }
        else
        {
            $fq1toRGID{$fastq1} = ".";
        }
        if($fq1toRG{$fastq1} =~ /LB:([^\t ]*)/)
        {
            $fq1toLib{$fastq1} = $1;
        }
        else
        {
            $fq1toLib{$fastq1} = ".";
        }
        if($fq1toRG{$fastq1} =~ /CN:([^\t ]*)/)
        {
            $fq1toCn{$fastq1} = $1;
        }
        else
        {
            $fq1toCn{$fastq1} = ".";
        }
         if($fq1toRG{$fastq1} =~ /PL:([^\t ]*)/)
        {
            $fq1toPl{$fastq1} = $1;
        }
        else
        {
            $fq1toPl{$fastq1} = ".";
        }
   }

    # Update the list of per sample bams if this is the first
    # appearance of the merge name (mergeToFQ1 has length 1)
    if(scalar(@{$mergeToFq1{$mergeName}}) == 1)
    {
        # if there is a specified sample id, use that, otherwise
        # use the mergename as the index.
        if($fq1toSm{$fastq1} eq '.')
        {
            push(@{$smToMerge{$mergeName}}, $mergeName);
        }
        else
        {
            push(@{$smToMerge{$fq1toSm{$fastq1}}}, $mergeName);
        }
    }
}
close(IN);

if($numBlanks > 0)
{
    my $lineString = "line";
    if($numBlanks > 1)
    {
        $lineString .= "s";
    }
    warn "\nWarning: skipped $numBlanks blank $lineString in $index_file\n";
}
if($numFieldSubs > 0)
{
    warn "\nWarning: Removed spaces from begining/end of each field in $index_file.\n";
}
if($numFieldSubs > 0)
{
    warn "\nWarning: ignoring extra tabs between fields of $index_file.\n";
}

if(($numHdrWarn > 0) || ($numBlanks > 0) || ($numFieldSubs > 0) || ($numFieldSubs > 0))
{
    warn "\n";
}


if($numInfer > 0)
{
    # Inferred some values, so output the index used.
    my $outFastqList = "$out_dir/Makefiles/fastq.list";
    open(OUT,"> ".($outFastqList || '-')) || die "Cannot open $outFastqList for writing.  $!\n";
    my $firstField = 1;
    foreach my $field (@fieldnames)
    {
        # Skip RG field since inferred fields mean that RG was not in the original header.
        next if($field eq "RG");

        if($firstField != 1)
        {
            print OUT "\t";
        }
        else
        {
            $firstField = 0;
        }
        print OUT $field;
    }
    foreach my $mergeName (sort (keys %mergeToFq1))
    {
        foreach my $fastq1 (@{$mergeToFq1{$mergeName}})
        {
            my $sep = "\n";
            foreach my $field (@fieldnames)
            {
                my $val;
                if($field eq "MERGE_NAME")
                {
                    $val = $mergeName;
                }
                elsif($field eq "FASTQ1")
                {
                    $val = $fastq1;
                }
                elsif($field eq "FASTQ2")
                {
                    $val = $fq1toFq2{$fastq1};
                }
                elsif($field eq "RGID")
                {
                    $val = $fq1toRGID{$fastq1};
                }
                elsif($field eq "SAMPLE")
                {
                    $val = $fq1toSm{$fastq1};
                }
                elsif($field eq "LIBRARY")
                {
                    $val = $fq1toLib{$fastq1};
                }
                elsif($field eq "CENTER")
                {
                    $val = $fq1toCn{$fastq1};
                }
                elsif($field eq "PLATFORM")
                {
                    $val = $fq1toPl{$fastq1};
                }
                elsif($field eq "RG")
                {
                    # Do not output RG.  Fields are inferred, meaning RG was not used.
                    next;
                }
                else
                {
                    $val = ".";
                }
                print OUT "$sep$val";
                $sep = "\t";
            }
        }
    }
}

# Output the bam index to the FINAL_BAM_DIR directory

# If the bam index file name is specified, write to it.
if(getConf('BAM_INDEX') || getConf('BAM_LIST'))
{
    my $bamIndex = getConf("BAM_INDEX");
    if(!$bamIndex)
    {
        $bamIndex = getConf("BAM_LIST");
    }
    open(BAM_IDX,">$bamIndex") || die "Cannot open $bamIndex for writing.  $!\n";

    my $ext = getConf("recab_EXT");
    if(uc(getConf("ALIGN_CRAM_OUTPUT")) eq "TRUE")
    {
        $ext = getConf("cram_EXT");
    }
    # Loop through %smToMerge and print the bam index
    foreach my $key (keys %smToMerge )
    {
        print BAM_IDX "$key";
        foreach (@{$smToMerge{$key}})
        {
            print BAM_IDX "\t".&getConf("FINAL_BAM_DIR")."/".$_.".$ext";
        }
        print BAM_IDX "\n";
    }
    close(BAM_IDX);
}

# Check that numjobs is not > than the number of merge files
if ($opts{numjobs} && ($opts{numjobs} > (scalar keys(%smToMerge))))
{
    die "ERROR: More jobs ($opts{numjobs}) specified than samples (".scalar keys(%smToMerge).").\n\t--numjobs : number of samples to run concurrently (previously '--numcs').\n\t--threads : number of jobs per sample (previously '--numjobs').\n";
}


#############################################################################
#   Done reading the index file, now process each merge file separately.
#############################################################################
my %mkcmds = ();
my ($saiFiles, $allPolish, $allSteps, $alnFiles, $polFiles);
foreach my $tmpmerge (sort (keys %mergeToFq1)) {
    my $mergeName = $tmpmerge;
    #   Reset generic variables
    $allPolish = '';
    $allSteps = '';
    $saiFiles = '';
    $alnFiles = '';
    $polFiles = '';
    $prevBwa = '';

    #----------------------------------------------------------------------------
    #   Create Makefile for this mergeFile
    #----------------------------------------------------------------------------
    #   Open the output Makefile for this merge file.
    my $makef = "$out_dir/Makefiles/align_$mergeName.Makefile";
    open(MAK,'>' . $makef) ||
        die "Unable to open '$makef' for writing.  $!\n";

    print MAK "OUT_DIR=" . getConf('OUT_DIR') . "\n";
    print MAK "SHELL := /bin/bash -o pipefail\n";
    print MAK ".DELETE_ON_ERROR:\n\n\n";

    #   Start
    print MAK "all: \$(OUT_DIR)/$mergeName.OK\n\n";
    print MAK "\$(OUT_DIR)/$mergeName.OK:";
    foreach my $step (@allSteps)
    {
        print MAK " ".getConf($step."_DIR") . "/$mergeName." . getConf($step."_EXT",1).".done";
    }
    print MAK "\n";
    print MAK doneTarget();

    # Loop through the defined steps.
    foreach my $step (@allSteps)
    {
        print MAK getConf($step."_DIR") . "/$mergeName." . getConf($step."_EXT",1).".done:";

        my @depends = split(/\s+/, getConf($step."_DEPEND",1));
        foreach my $depend (@depends)
        {
            print MAK " " . getConf($depend."_DIR",1) . "/$mergeName." . getConf($depend."_EXT",1).".done";
        }
        print MAK "\n";
        print MAK "\tmkdir -p \$(\@D)\n";
        my $cmd = getConf($step."_CMD",1) . " 2> \$(basename \$\@).log";
        print MAK logCatchFailure($step, $cmd, "\$(basename \$\@).log");
        if(getConf($step."_RMDEP"))
        {
            print MAK doneTarget(1);
        }
        else
        {
           print MAK doneTarget();
        }
    }

    #   Get the commands for each fastq that goes into this
    foreach my $tmpfastq1 (@{$mergeToFq1{$mergeName}}) {
        my $fastq1 = $tmpfastq1;
        my $fastq2 = $fq1toFq2{$fastq1};
        my $alnOutFile = "";

        my $rgid = $fq1toRGID{$fastq1};
        my $sample = $fq1toSm{$fastq1};
        my $library = $fq1toLib{$fastq1};
        my $center = $fq1toCn{$fastq1};
        my $platform = $fq1toPl{$fastq1};
        my $rgCommand = "";

        if ( (getConf('MAP_TYPE') eq 'BWA') ||
             (getConf('MAP_TYPE') eq 'BWA_MEM') )
        {
            if($rgid ne ".")
            {
                if (getConf('MAP_TYPE') eq 'BWA') { $rgCommand = "-r "; }
                else { $rgCommand = "-R "; }

                if(defined $fq1toRG{$fastq1})
                {
                    $rgCommand .= $fq1toRG{$fastq1};
                }
                else
                {
                    $rgCommand .= " \"\@RG\\tID:$rgid";
                    $rgCommand .= "\\tSM:$sample";
                    #   Only add the optional rg fields if they are specified
                    if ($library ne ".")  { $rgCommand .= "\\tLB:$library"; }
                    if ($center ne '.')   { $rgCommand .= "\\tCN:$center"; }
                    if ($platform ne '.') { $rgCommand .= "\\tPL:$platform"; }
                    $rgCommand .= '"';
                }
            }
            $alnOutFile = mapBwa($fastq1, $fastq2, $rgCommand);
        }
        elsif (getConf('MAP_TYPE') eq 'MOSAIK')
        {
            if ($rgid ne ".") {
                $rgCommand = "-id $rgid";
                $rgCommand .= " -sam $sample";
                # only add the rg fields if they are specified.
                if ($library ne ".")  { $rgCommand .= " -ln $library"; }
                if ($center ne '.')   { $rgCommand .= " -cn $center"; }
                if ($platform ne '.') { $rgCommand .= " -st $platform"; }
            }
            $alnOutFile = mapMosaik($fastq1, $fastq2, $rgCommand);
        }
        else
        {
            die "ERROR: Somehow config file key is unknown MAP_TYPE= " . getConf('MAP_TYPE') . "\n";
        }

        my $bam = $fastq1;
        if(($bam !~ s/fastq.gz$/bam/) && ($bam !~ s/fastq$/bam/))
        {
            $bam .= ".bam";
        }

        # Add the polish step for each fastq/pair.
        print MAK getConf('POL_TMP') . "/$bam.done: $alnOutFile\n";
        print MAK "\tmkdir -p \$(\@D)\n";
        print MAK logCatchFailure('polishBam', getConf("polish_CMD"), "\$(basename \$\@).log");
        print MAK doneTarget(1);

        $polFiles .= getConf('POL_TMP') . "/$bam ";
        $allPolish .= getConf('POL_TMP') . "/$bam.done ";
    }

    #   Maybe rather than using full fastq path in subdirectories, use the merge name?
    #   for the first set of subdirs, but what if still not unique?  or does it not
    #   matter if we cleanup these files???
    #   FOR EXAMPLE, SARDINIA, multiple runs for a sample have the same fastq names,
    #   so easiest to keep the subdirs.

    # Merge the Polished BAMs
    print MAK getConf('MERGE_TMP') . "/$mergeName.merged.bam.done: $allPolish\n";
    print MAK "\tmkdir -p \$(\@D)\n";
    my $mergeBams = getConf('BAM_EXE') . " mergeBam --ignorePI --out \$(basename \$\@) \$(subst " .
        getConf('POL_TMP') . ",--in " . getConf('POL_TMP') . ",\$(basename \$^)) ".getConf("BAMUTIL_THINNING");

    # If there is only 1 bam, just link instead of merging.
    if((scalar @{$mergeToFq1{$mergeName}}) <= 1)
    {
        # only one bam, so link it to the final name.
        $mergeBams = "ln \$(basename \$^) \$(basename \$\@)";
    }
    print MAK logCatchFailure('MergingBams', $mergeBams, "\$(basename \$\@).log");
    print MAK doneTarget(1);

    print MAK $allSteps;
    close MAK;
    warn "Created $makef\n";

    my $s = "make -f $makef " . getConf("MAKE_OPTS");
    if ($opts{threads}) {
        $s .= " -j ".$opts{threads};
    }
    $s .= " > $makef.log";
    $mkcmds{$mergeName} = $s;
}

#--------------------------------------------------------------
#   Makefile created, commands built in %mkcmds
#   Normal case is to run these, either locally or in batch mode
#--------------------------------------------------------------
warn '-' x 69 . "\n";

if ($opts{'dry-run'}) {
    die "#  These commands would have been run:\n" .
        '  ' . join("\n  ",sort(values %mkcmds)) . "\n";
}

#   We now have an array of commands to run launch and wait for them
warn "Waiting while samples are processed...\n";
my $t = time();

my $totaljobs = 1;
if(defined $opts{numjobs}){ $totaljobs = $opts{numjobs}; }


if(defined $opts{threads}) { $totaljobs *= $opts{threads}; }
if((! defined(getConf('BATCH_TYPE'))) || (getConf('BATCH_TYPE') eq ''))
{
    setConf('BATCH_TYPE', 'local');
}

if((getConf('BATCH_TYPE') eq 'local') && ($totaljobs > $opts{maxlocaljobs}))
{
    die "ERROR: can't run $totaljobs jobs with 'BATCH_TYPE = local', " .
        "max is $opts{maxlocaljobs}\n" .
        "Rerun with a different 'BATCH_TYPE' or override the local maximum ".
        "using '--maxlocaljobs $totaljobs'\n" .
        "#  These commands would have been run:\n" .
        '  ' . join("\n  ",sort(values %mkcmds)) . "\n";
}

#--------------------------------------------------------------
#   Generate the runcluster commands in a single Makefile
#--------------------------------------------------------------
my $allMakef = "$out_dir/Makefiles/alignAll.Makefile";
open(ALL_MAK,'>' . $allMakef) ||
die "Unable to open '$allMakef' for writing.  $!\n";

print ALL_MAK ".PHONY : all ".join(" ",sort(keys %mkcmds))."\n\n";
print ALL_MAK "all: ".join(" ",sort(keys %mkcmds))."\n\n";

#   Build runcluster command to be run, execute it for each command to be run
my $unsetMakeFlags = 'MAKEFLAGS=$(patsubst --jobserver-fds=%,,$(patsubst -j,,$(MAKEFLAGS)))';
my $runcmd = $opts{runcluster} . ' -bashdir ' . "$out_dir/Makefiles/jobfiles";
if (getConf('BATCH_OPTS')) { $runcmd .= " -opts '" . getConf('BATCH_OPTS') . "'"; }
if ($opts{verbose}) { $runcmd .= ' -verbose'; }
$runcmd .= ' ' . getConf('BATCH_TYPE');
my $errs = 0;
foreach my $tgt (sort(keys %mkcmds))
{
    print ALL_MAK "$tgt:\n";
    print ALL_MAK "\t" . $unsetMakeFlags . ' ' . $runcmd . " '" . $mkcmds{$tgt} . "'\n\n";
}
close ALL_MAK;
my $allMakeCmd = "make -f $allMakef";
if ($opts{numjobs})
{
    $allMakeCmd .= " -j ".$opts{numjobs};
}
$allMakeCmd .= " > $allMakef.log 2> $allMakef.err";
print STDERR "Running $allMakeCmd...\n\n";
system($allMakeCmd) && $errs++;
if ($errs || $opts{verbose}) { warn "###### $errs commands failed ######\n"; }

$t = time() - $t;
print STDERR "Processing finished in $t secs";
if ($errs) {
        print STDERR " WITH ERRORS.  Check the logs:\n" .
        "   $allMakef.err\n" .
        "   $allMakef.log\n".
        "  TYPE=".getConf('BATCH_TYPE')."\n" .
        "  OPTS=".getConf('BATCH_OPTS')."\n" .
        "  CMDS=" . join("\n    ", sort(keys %mkcmds)) . "\n";

        if (not open(my $errfile, "$allMakef.err")) {
            warn "failed to open $allMakef.err";
        } else {
            print STDERR <$errfile>;
            close($errfile);
        }
}
else {
    print STDERR " with no errors reported\n";
    #   Call runcluster to figure out if this was batch or interactive
    my $cmd = $opts{runcluster} . ' ' . getConf('BATCH_TYPE') . ' runcluster-show-details';
    $_ = `$cmd`;
    if (/Type=(.)/) {
        if ("$1" eq 'b') {
            print STDERR "\nReal tasks were submitted to '".getConf('BATCH_TYPE')."' and probably are not finished\n";
        }
    }
}
exit($errs);


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
    $makeCmd .= "\trm -f $log\n";
    return $makeCmd;
}

#--------------------------------------------------------------
#   cmd = alignBwa(fastq, sai)
#
#   Generate Makefile line for alignment$tmpFastq1
#--------------------------------------------------------------
sub alignBwa {
    my ($fastq, $sai) = @_;

    my $alnTarget = getConf('SAI_TMP') . '/' . $sai . ".done:";
    if($oneBwa)
    {
        $alnTarget .= "$prevBwa";
        $prevBwa = getConf('SAI_TMP') . '/' . $sai . ".done";
    }

    $alnTarget .= "\n\tmkdir -p \$(\@D)\n";

    my $alnCmd = getConf('BWA_EXE') . ' aln ' . getConf('BWA_QUAL') . ' ' .
        getConf('BWA_THREADS') . ' ' . getConf('REF') .
        " $fastq -f \$(basename \$\@) 2> " . "\$(basename \$\@).log";
    $alnTarget .= logCatchFailure("aln", $alnCmd, "\$(basename \$\@).log");
    $alnTarget .= doneTarget();
  return $alnTarget;
}

#--------------------------------------------------------------
#   CheckFor_REF_File($ext, removeExt)
#
#   Check for a refernce file. If not generate a warning
#   Be sure to include the '.' if applicable in the passed in
#   extension.
#   If removeExtension is true/1, remove the reference extension (and '.')
#   prior to appending the specified extention.  If it is undefined/false/0,
#   do not remove the extension prior to appending.
#   Return boolean if file was missing:  0 (file is found) or 1 (file missing)
#--------------------------------------------------------------
sub CheckFor_REF_File {
    my ($ext, $removeExtension) = @_;
    if(! defined ($removeExtension)) { $removeExtension = 0; }

    my $file = getConf('REF');

    if($removeExtension)
    {
        $file =~ s/\.[^.]*$//;
    }

    $file .= $ext;
    if(-r $file)
    {
        if(-s $file)
        {
            return 0;
        }
        warn "ERROR: Required file derived from REF has size 0: $file\n";
        warn "See ${GCURL} for information about building this file\n";
        return 1;
    }
    warn "ERROR: Could not read required file derived from REF: $file\n";
    warn "See ${GCURL} for information about building this file\n";
    return 1;
}

#--------------------------------------------------------------
#   cmd = mapBwa(fastq1, fastq2, rgCommand)
#
#   Generate Makefile line for a read pair (alignment)
#   Does not seem to return anything, so it must be setting
#   global variables. If so, what? Not obvious what are the ins and outs
#
#   Terrible interfaces here - requires global variables  yuk!
#--------------------------------------------------------------
sub mapBwa {
    my ($fastq1, $fastq2, $rgCommand) = @_;

    # There are two types of BWA, mem & non-mem.
    # BWA_MEM is a 1 step process, while the other is a 2 step process.

    my $bam = $fastq1;
    if(($bam !~ s/fastq.gz$/bam/) && ($bam !~ s/fastq$/bam/))
    {
        $bam .= ".bam";
    }
    my $absFastq1 = getAbsPath($fastq1, 'FASTQ');
    my $absFastq2 = '';
    if($fastq2 ne '.')
    {
        $absFastq2 = getAbsPath($fastq2, 'FASTQ');
    }

    $alnFiles .= getConf('ALN_TMP') . "/$bam ";
    my $finalBwaBam =  getConf('ALN_TMP') . "/$bam.done";

    $allSteps .= "$finalBwaBam:";
    my $rmFastq = getConf("BWA_RM_FASTQ");
    my $rmStr = "";
    if(defined $rmFastq && $rmFastq && (uc($rmFastq) ne "FALSE"))
    {
        $rmStr = "$absFastq1 $absFastq2";
    }

    if(getConf('MAP_TYPE') eq 'BWA_MEM')
    {
        # No dependencies.
        if($oneBwa)
        {
            # Depend on the previous BWA.
            $allSteps .= $prevBwa;
            $prevBwa = $finalBwaBam;
        }
        $allSteps .= "\n";
        $allSteps .= "\tmkdir -p \$(\@D)\n";
        my $bwaMemOpts = " " . getConf("BWA_MEM_OPTS");
        if($bwaMemOpts eq ' ')
        {
            $bwaMemOpts = "";
        }
        # BWA_MEM command.
        my $bwacmd = "(" . getConf('BWA_EXE') . " mem " . getConf("BWA_THREADS") .
                     "$bwaMemOpts" .
                     " -M $rgCommand " . getConf('REF') . " $absFastq1 $absFastq2 | " .
                     getConf('SAMTOOLS_EXE') . " view -uhS - | " .
                     getConf('SAMTOOLS_SORT_EXE') . " sort -m " . getConf('SORT_MAX_MEM') .
                     " - \$(basename \$(basename " . "\$\@))) 2> \$(basename \$\@).log";
        $allSteps .= logCatchFailure("bwa-mem", $bwacmd, "\$(basename \$\@).log");
        $allSteps .= doneTarget("", $rmStr);
    }
    else
    {
        # Regular BWA with 2 steps and sai files.
        # Dependent on the SAI files.
        my $sai1 = $fastq1;
        if(($sai1 !~ s/fastq.gz$/sai/) && ($sai1 !~ s/fastq$/sai/))
        {
            $sai1 .= ".sai";
        }

        $saiFiles .=  getConf('SAI_TMP') . "/$sai1 ";
        $allSteps .= ' ' . getConf('SAI_TMP') . "/$sai1.done";

        my $samsesampe = "samse";

        my $sai2 = "";
        if ($fastq2 ne ".") {
            $sai2 = $fastq2;
            if(($sai2 !~ s/fastq.gz$/sai/) && ($sai2 !~ s/fastq$/sai/))
            {
                $sai2 .= ".sai";
            }
            $saiFiles .=  getConf('SAI_TMP')."/$sai2 ";
            $allSteps .= ' ' . getConf('SAI_TMP') . "/$sai2.done";
            $samsesampe = "sampe";
        }

        # Create the directory.
        $allSteps .= "\n\tmkdir -p \$(\@D)\n";

        # Write the samse/sampe command.
        my $log = "\$(basename \$(basename \$\@)).$samsesampe.log";
        my $cmd = "(" . getConf('BWA_EXE') . " $samsesampe $rgCommand " . getConf('REF') .
            " \$(basename \$^) $absFastq1 $absFastq2 | " . getConf('SAMTOOLS_EXE') . " view -uhS - | " .
            getConf('SAMTOOLS_SORT_EXE') . " sort -m " . getConf('SORT_MAX_MEM') .
            " - \$(basename \$(basename " . "\$\@))) 2> $log";
        $allSteps .= logCatchFailure("$samsesampe", $cmd, $log);

        $allSteps .= doneTarget(1, $rmStr);

        # Add the aln steps.
        $allSteps .= alignBwa($absFastq1, $sai1);
        if($absFastq2 ne '') { $allSteps .= alignBwa($absFastq2, $sai2); }
    }
    return($finalBwaBam);
}

#--------------------------------------------------------------
#   cmd = mapMosaik(fastq1, fastq2, rgCommand)
#
#   Generate Makefile line for a read pair (alignment)
#   Does not seem to return anything, so it must be setting
#   global variables. If so, what? Not obvious what are the ins and outs
#
#   Terrible interfaces here - requires global variables  yuk!
#--------------------------------------------------------------
sub mapMosaik {
    my ($fastq1, $fastq2, $rgCommand) = @_;

    my $absFastq1 = getAbsPath($fastq1, 'FASTQ');
    my $absFastq2 = '';
    if($fastq2 ne '.') { $absFastq2 = getAbsPath($fastq2, 'FASTQ'); }

    my $mkb = $fastq1;
    if(($mkb !~ s/fastq.gz$/mkb/) && ($mkb !~ s/fastq$/mkb/))
    {
        $mkb .= ".mkb";
    }
    my $mkbFiles .= getConf('MKB_TMP') . "/$mkb ";
    my $mosaikBuildDone = getConf('MKB_TMP') . "/$mkb.done";

    my $premoFile = $mkb;
    $premoFile =~ s/mkb/premo.txt/;
    my $preMosaikDone = getConf('MKB_TMP') . "/$premoFile.done";

    my $bam = $mkb;
    $bam =~ s/mkb/bam/;
    $alnFiles .= getConf('ALN_TMP') . "/$bam ";
    my $alignDone = getConf('ALN_TMP') . "/$bam.done";
    my $sortDone = $alignDone;
    $sortDone =~ s/.bam.done/.sort.bam.done/;

    #
    #   Sort the bam.  Depends on the aligned bam.
    #
    $allSteps .= "$sortDone: $alignDone\n";
    $allSteps .= "\tmkdir -p \$(\@D)\n";

    my $sortPrefix = "\$(basename \$(basename \$\@))";
    my $sortcmd = getConf('SAMTOOLS_SORT_EXE') . " sort -m " . getConf('SORT_MAX_MEM') .
        " \$(basename \$^) $sortPrefix 2> $sortPrefix.log";
    $allSteps .= "\t$sortcmd\n";
    $allSteps .= logCatchFailure('sort', "(grep -q -i -e abort -e error -e failed $sortPrefix.log; [ \$\$? -eq 1 ])", "$sortPrefix.log");
    $allSteps .= doneTarget();

    #
    #     Run MosaikAlign to create the bam.  Depends on the Mosaik Build step.
    #
    $allSteps .= "$alignDone: $mosaikBuildDone\n";
    $allSteps .= "\tmkdir -p \$(\@D)\n";

    my $mosaikRef = getConf('REF');
    $mosaikRef =~ s/\.[^.]+$/.dat/g;                        # Escape single quotes
    my $mosaikJmp = $mosaikRef;
    $mosaikJmp =~ s/\.dat$/_15/;

    my $mosaikAlign = getConf('MOSAIK_ALIGN_EXE') . " " .
        getConf("MOSAIK_THREADS") .
        " -in \$(basename \$\^) -ia $mosaikRef -j $mosaikJmp -annse " .
        getConf('SE_ANN') . " -annpe " . getConf('PE_ANN') .
        " -out \$(basename \$(basename \$\@)) ".getConf("MOSAIK_HS")." ".getConf("MOSAIK_MHP")." -act 25 > \$(basename \$\@).log";
    $allSteps .= logCatchFailure('mosaikAlign', $mosaikAlign, "\$(basename \$\@).log");
    $allSteps .= doneTarget();

    #
    #   Run MosaikBuild to create the intermediate file (no dependencies)
    #
    $allSteps .= "$mosaikBuildDone:";
    my $mosaikBuild = getConf('MOSAIK_BUILD_EXE') . " -q $absFastq1 ";

    my $mfl = "";
    if($fastq2 ne '.')
    {
        # paired end, add 2nd fastq and dependency on pre-mosaik step.
        $mosaikBuild .= "-q2 $absFastq2 ";
        $allSteps .= " $preMosaikDone";

        $mfl = "-mfl `grep -oP '(?<=\-mfl\" : ).*(?=,)' \$(basename \$\^)`";
    }

    if($mfl)
    {
        $mosaikBuild .= "$mfl ";
    }

    $allSteps .= "\n\tmkdir -p \$(\@D)\n";

    $mosaikBuild .= "-out \$(basename \$\@) $rgCommand > \$(basename \$\@).log";
    $allSteps .= logCatchFailure('mosaikBuild', $mosaikBuild, "\$(basename \$\@).log");
    #  $allSteps .= "\t$mosaikBuild\n";
    $allSteps .= doneTarget();

    #
    #   Run pre-Mosaik step to get values only if paired end.
    #
    if($fastq2 ne '.')
    {
        # Paired end, so run pre-mosaik step.
        $allSteps .= "$preMosaikDone:\n";
        $allSteps .= "\tmkdir -p \$(\@D)\n";

        my ($alignexe, $mosaikBinDir) =  fileparse(getConf('MOSAIK_ALIGN_EXE'));

        my $premo = getConf('PREMO_EXE') . " -ref $mosaikRef -jmp $mosaikJmp -annse ".
            getConf("SE_ANN")." -annpe ".getConf("PE_ANN").
            " -mosaik $mosaikBinDir -fq1 $absFastq1 -fq2 $absFastq2".
            " -out \$(basename \$\@) ".getConf("MOSAIK_HS")." ".getConf("MOSAIK_MHP").
            " -st $fq1toPl{$fastq1} -tmp ".getConf('MKB_TMP')." > \$(basename \$\@).log";
        $allSteps .= logCatchFailure('preMosaik', $premo, "\$(basename \$\@).log");
        $allSteps .= doneTarget();
    }
    return($sortDone);
}



#--------------------------------------------------------------
#   cmd = doneTarget(rmDep)
#
#
#   Done with the target, so write the done marker.
#--------------------------------------------------------------
sub doneTarget {
    my ($rmDep, $rmFiles) = @_;
    my $rmTmp = "";
    if((defined($rmDep) && $rmDep) && (!getConf('KEEP_TMP')))
    {
        $rmTmp = "\n\trm -f \$(basename \$^)";
#        print $rmTmp;
    }
    if((defined $rmFiles && $rmFiles) && (!getConf('KEEP_TMP')))
    {
        $rmTmp .= "\n\trm -f $rmFiles";
    }

#    return("\t\@echo `date +'%F.%H:%M:%S'` touch \$\@; touch \$\@\n\n");
    return("\t\@echo `date +'%F.%H:%M:%S'` touch \$\@; touch \$\@$rmTmp\n\n");
}

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

align.pl - Convert FASTQs to BAMs

=head1 SYNOPSIS

  align.pl --test ~/testaligner    # Run short self check
  align.pl --conf ~/mydata.conf --out ~/testdir
  align.pl --batchtype slurm --conf ~/mydata.conf --index ~/mydata.index
  align.pl --conf ~/mydata.conf --index ~/mydata.index --ref /usr/local/ref


=head1 DESCRIPTION

Use this program to generate a Makefile which will run the programs
to convert one or more FASTQ files to a single BAM file.

There are many inputs to this script which are most often specified in a
configuration file.

The official documentation for this program can be found at
B<http://genome.sph.umich.edu/wiki/Mapping_Pipeline>

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

  FASTQ_LIST = fastqList.txt
  # References
  REF_DIR = /gotcloud/test/align/chr20Ref
  AS = NCBI37
  REF = $(REF_DIR)/human_g1k_v37_chr20.fa
  DBSNP_VCF =  $(REF_DIR)/dbsnp.b130.ncbi37.chr20.vcf.gz
  HM3_VCF = $(REF_DIR)/hapmap_3.3.b37.sites.vcf.gz

The B<list> file specifies information about individuals and paths to
fastq data for a SNP. The data is tab delimited.
The first line (#FASTQ_PREFIX=) is optional and will specify a path which is added to the path
for each FASTQ to provide the complete absolute path to the FASTQ
(this is equivalent to setting the option B<fastq_prefix>).
The next line is a header line which identifies this as a valid indexFile.
A sample might look like this (tabs are not visible):

  #FASTQ_PREFIX=/net/gateway/home/myuser/Run_0601/Data/Intensities/Fastqs
  MERGE_NAME    FASTQ1  FASTQ2  RGID    SAMPLE  LIBRARY CENTER  PLATFORM
  Smp1 Smp_1/File1_R1.fastq.gz Smp_1/File1_R2.fastq.gz RGID1   SmpID1 Lib1 UM ILLUMINA
  Smp1 Smp_1/File2_R1.fastq.gz Smp_1/File2_R2.fastq.gz RGID1a  SmpID1 Lib1 UM ILLUMINA
  Smp2 Smp_2/File1_R1.fastq.gz Smp_2/File1_R2.fastq.gz RGID2   SmpID2 Lib2 UM ILLUMINA
  Smp2 Smp_2/File2_R1.fastq.gz Smp_2/File2_R2.fastq.gz RGID2   SmpID2 Lib2 UM ILLUMINA


=head1 OPTIONS

=over 4

=item B<--batchopts  options_string>

Specifies options to be passed to the batch engine.
You almost always will need to quote I<options_string>.
This is only valid if B<batchtype> is specified.

=item B<--batchtype local | slurm | sge | pbs | flux | mosix>

Specifies the batch system to be used when executing the commands.
These determine exactly how B<runcluster> will run the command.
the type 'flux' is an alias for 'pbs'.
The default is B<local>.

=item B<--conf file>

Specifies a space delimited list of configuration files to be used.
The first file in the list has the highest precedence in the case of repeated values.

=item B<--dry-run>

If specified no commands will actually be executed, but you will be shown
the commands that would be run.

=item B<--fastq_prefix dir>

This specifies a directory prefix which should be added to relative paths in the fastq list file.

=item B<--ref_prefix dir>

This specifies a directory prefix which should be added to relative reference file paths.

=item B<--base_prefix dir>

This specifies a directory prefix which should be added to all relative paths if a different prefix is not specified.

=item B<--help>

Generates this output.

=item B<--list str>

Specifies the name of the file containing the table of fastqs to process.
This value must be set in the configuration file or specified by this option.

=item B<--keeplog>

If specified, the log files used in this process will not be deleted.
The default is to remove the log files.

=item B<--keeptmp>

If specified, the temporary files used in this process will not be deleted.
The default is to remove the temporary files.

=item B<--cram>

Write the final output files in CRAM, removing the intermediate BAM files (default is to have the final output files in BAM).

=item B<--numjobs N>

Specifies the number of samples to be processed concurrently.
This effectively defaults to '2'.
The number of processesors to be used at the same time on the local machine
or on the cluster is I<-numjobs> times I<-threads>.

=item B<--threads N>

Specifies the number of jobs to run per sample. In practice this is
the value of the B<-j> flag for the make command.
This effectively defaults to '1'.
If not specified, the flag is not set on the make command to be executed.
The number of processesors to be used at the same time on the local machine
or on the cluster is I<-numjobs> times I<-threads>.

=item B<--out_dir dir>

Specifies the toplevel directory where the output is created.

=item B<--ref_dir dir>

Specifies the location of the reference files, overriding the configuration
value of REF_DIR.

=item B<--runcluster path>

Specifies the path to the script which is called to invoke the command to be run
in batch mode.
This defaults to B<../scripts/runcluster.pl>, relative to where this script is installed.
This script expects the first parameter to be B<batchtype>, followed by the
command to be executed.

=item B<--test out_dir>

Run a small test case putting the output in the directory B<out_dir> and verify the output.

=item B<--verbose>

Specifies that additional details are to be printed out.

=item B<--maxlocaljobs N>

Specifies the maximum number of jobs that can be run with batchtype local (the default).  Default is 10.

=item B<--gotcloudroot dir>

Specifies an alternate path to other gotcloud files rather than using the path to this script.

=item B<--pipelinedefaults file>

Specifies an alternate set of default settings rather than using '$gotcloudroot/bin/gotcloudDefaults.conf'.

=item B<--phonehome file>

Specifies an alternate phonehome call rather than using '$gotcloudroot/scripts/gcphonehome.pl -verbose -pgmname GotCloud align'.

=item B<--calcstorage file>

Specifies an alternate phonehome script rather than using '$gotcloudroot/scripts/gcphonehome.pl align'.

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
