#!/usr/bin/perl
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
#          -index $d/indexFile.txt -ref $d/../chr20Ref/ \
#          -fastq $d   -out ~/outdata
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
use File::Basename;
use Cwd;
use Cwd 'abs_path';

my %hConf = ();

#   Everything is relative to where this program lives
#   so it must be in a 'bin' directory.  Symlinks are tricky
$_ = abs_path($0);
my ($me, $scriptdir, $mesuffix) = fileparse($_, '\.pl');
$scriptdir = abs_path($scriptdir);
if ($scriptdir !~ /(.*)\/bin/) { die "Unable to set basepath. No 'bin' found in '$scriptdir'\n"; }
my $basepath = $1;

push @INC,$scriptdir;                       # use lib is a BEGIN block and does not work
require Multi;

setConf("GOTCLOUD_ROOT", $basepath);         # Get rid of this someday

(my $version = '$Revision: 1.1 $ ') =~ tr/[0-9].//cd;

#############################################################################
## Global Variables
############################################################################
my $fastq1;
my $fastq2;
my $rgid;
my $sample;
my $library;
my $center;
my $platform;
my $rgCommand;
my $mergeName;

my $allPolish = '';
my $allSteps = '';
my $saiFiles = '';
my $alnFiles = '';
my $polFiles = '';
my $dedupFiles = '';
my $recalFiles = '';

#--------------------------------------------------------------
#   Initialization - Sort out the options and parameters
#--------------------------------------------------------------
my %opts = (
    runcluster => "$basepath/scripts/runcluster.pl",
    pipelinedefaults => $scriptdir . '/gotcloudDefaults.conf',
    batchtype => '',
    batchopts => '',
    keeptmp => 0,
    keeplog => 0,
    conf => '',
    verbose => 0,
);
Getopt::Long::GetOptions( \%opts,qw(
    help
    dry-run|dryrun
    batchtype=s
    batchopts=s
    test=s
    out_dir|outdir=s
    conf=s
    index_file|indexfile=s
    ref_dir|refdir=s
    ref_prefix|refprefix=s
    fastq_prefix|fastqprefix=s
    base_prefix|baseprefix=s
    keeptmp
    keeplog
    verbose
    numjobspersample|numjobs=i
    numconcurrentsamples|numcs=i
)) || die "Failed to parse options\n";

#   Simple help if requested, sanity check input options
if ($opts{help}) {
    warn "$me$mesuffix [options]\n" .
        "Version $version\n" .
        "Use this to generate makefiles for a single session whatever it is.\n" .
        "More details available by entering: perldoc $0\n\n";
    if ($opts{help}) { system("perldoc $0"); }
    exit 1;
}

#   Special case for convenient testing
if ($opts {test}) {
    my $outdir=abs_path($opts{test});
    system("mkdir -p $outdir") &&
        die "Unable to create directory '$outdir'\n";
    my $testoutdir = $outdir . '/aligntest';
    print "Removing any previous results from: $testoutdir\n";
    system("rm -rf $testoutdir") &&
        die "Unable to clear the test output directory '$testoutdir'\n";
    print "Running GOTCLOUD TEST, test log in: $testoutdir.log\n";
    my $testdir = $basepath . '/test/align';
    if(! -r $testdir)
    {
        die "ERROR, $testdir does not exist, please download the test data to that directory\n";
    }
    my $cmd = "$0 -conf $testdir/test.conf -out $testoutdir";
    system($cmd) &&
        die "Failed to generate test data. Not a good thing.\nCMD=$cmd\n";
    $cmd = "$basepath/scripts/diff_results_align.sh $outdir $basepath/test/align/expected";
    system($cmd) &&
        die "Comparison failed, test case FAILED.\nCMD=$cmd\n";
    print "Successfully ran the test case, congratulations!\n";
    exit;
}
if ($opts{batchtype} eq 'flux') { $opts{batchtype} = 'pbs'; }
$opts{runcluster} = abs_path($opts{runcluster});    # Make sure this is fully qualified

if ((! $opts{conf}) || (! -r $opts{conf})) {
    die "Conf file '$opts{conf}' does not exist or was not specified\n";
}
$opts{conf} = abs_path($opts{conf});

#--------------------------------------------------------------
#   Set configuration variables from comand line options
#--------------------------------------------------------------
my $out_dir = '';
if ($opts{out_dir}) {
    $out_dir = abs_path($opts{out_dir});
    setConf('OUT_DIR', $out_dir);
}

my $ref_dir = '';
if ($opts{ref_dir}) {
    $ref_dir = abs_path($opts{ref_dir});
    setConf('REF_DIR', $ref_dir);
}

if ($opts{ref_prefix}) {
    setConf('REF_PREFIX', $opts{ref_prefix});
}

if ($opts{fastq_prefix}) {
    setConf('FASTQ_PREFIX', $opts{fastq_prefix});
}

if ($opts{base_prefix}) {
    setConf('BASE_PREFIX', $opts{base_prefix});
}

# Check if index_file was specified on the command line prior to reading defaults.
if ($opts{index_file}) {
    setConf('INDEX_FILE', $opts{index_file});
}

if($opts{keeptmp})
{
  setConf('KEEP_TMP', $opts{keeptmp});
}
if($opts{keeplog})
{
  setConf('KEEP_LOG', $opts{keeplog});
}

#--------------------------------------------------------------
#   Load configuration variables from conf file
#   Variables already set will NOT be replaced
#   Make sure paths for variables are fully qualified
#--------------------------------------------------------------
loadConf($opts{conf});

$ref_dir = getConf('REF_DIR');
if ($ref_dir) {
    $ref_dir = abs_path($ref_dir);
    setConf('REF_DIR', $ref_dir);
}

my $index_file = getConf('INDEX_FILE');
if (! $index_file) {
    die "Index file (-indexfile file) was not specified\n";
}
$index_file = getAbsPath($index_file);    # If path not provided, use cwd
setConf('INDEX_FILE', $index_file);

$out_dir = getConf("OUT_DIR");
if($out_dir ne '')
{
  $out_dir = abs_path(getConf("OUT_DIR"));
  setConf('OUT_DIR', $out_dir);
}

#   Last step, load default config values. These are almost never
#   seen or set by the user, buf if they were set, these defaults
#   are NOT used.
loadConf($opts{pipelinedefaults});

#--------------------------------------------------------------
#   Check required settings
#--------------------------------------------------------------
if (getConf("OUT_DIR") eq '')
{
    die "Output directory (-out_dir dir) was not specified\n";
}

my $missingReqFile = "0";
# Check to see if the old REF is set instead of the new one.
if( getConf("FA_REF") )
{
    warn "ERROR: FA_REF is deprecated and has been replaced by REF, please update your configuration file and rerun\n";
    $missingReqFile = "1";
}
if( getConf("FASTQ") )
{
    warn "ERROR: FASTA is deprecated and has been replaced by FASTQ_PREFIX, please update your configuration file and rerun\n";
    $missingReqFile = "1";
}

# Verify the REF file is readable.
my $newpath = getAbsPath(getConf("REF"), "REF");
$hConf{"REF"} = $newpath;
if(! -r getConf("REF"))
{
    warn "ERROR: Could not read required REF: ".getConf("REF")."\n";
    $missingReqFile = "1";
}

# Verify the DBSNP file is readable.
$newpath = getAbsPath(getConf("DBSNP_VCF"), "REF");
$hConf{"DBSNP_VCF"} = $newpath;
if(! -r getConf("DBSNP_VCF"))
{
    warn "ERROR: Could not read required DBSNP_VCF: ".getConf("DBSNP_VCF")."\n";
    $missingReqFile = "1";
}

if($hConf{RUN_VERIFY_BAM_ID} eq "1")
{
    $newpath = getAbsPath(getConf("HM3_VCF"), "REF");
    $hConf{"HM3_VCF"} = $newpath;

    if(! -r getConf("HM3_VCF"))
    {
        warn "ERROR: Could not read required HM3_VCF: ".getConf("HM3_VCF")."\n";
        $missingReqFile = "1";
    }
}

if(($hConf{RUN_QPLOT} eq "1") && ! -r getConf("REF").".GCcontent")
{
    warn "ERROR: Could not read required file derived from REF: ".getConf("REF").".GCcontent\n";
    warn "See http://genome.sph.umich.edu/wiki/GotCloud:_Genetic_Reference_and_Resource_Files#Generating_GCContent_File for information about building this file\n";
    $missingReqFile = "1";
}

# Check for the required sub REF files.
if(getConf("MAP_TYPE") eq "BWA")
{
    foreach my $extension (qw(amb ann bwt fai pac rbwt rpac rsa sa))
    {
        if(! -r getConf("REF").".$extension")
        {
            warn "ERROR: Could not read required file derived from REF: ".getConf("REF").".$extension\n";
            warn "See http://genome.sph.umich.edu/wiki/GotCloud:_Genetic_Reference_and_Resource_Files#Generating_BWA_Reference_Files for information about building this file\n";
            $missingReqFile = "1";
        }
    }
}
elsif(getConf("MAP_TYPE") eq "MOSAIK")
{
    my $prefix = getConf("REF");
    $prefix =~ s/\.[^.]*$//;
    print "\n$prefix\n";
    for my $extension (qw(.dat _15_keys.jmp _15_meta.jmp _15_positions.jmp))
    {
        if(! -r "$prefix$extension")
        {
            warn "ERROR: Could not read required file derived from REF: $prefix$extension\n";
            warn "See http://genome.sph.umich.edu/wiki/GotCloud:_Genetic_Reference_and_Resource_Files#Generating_Mosaik_Reference_Files for information about building this file\n";
            $missingReqFile = "1";
        }
    }

    # Check for ANN files
    if(! -r getConf("SE_ANN"))
    {
        warn "ERROR: Could not read required SE_ANN: ".getConf("SE_ANN")."\n";
            warn "See http://genome.sph.umich.edu/wiki/GotCloud:_Genetic_Reference_and_Resource_Files#Generating_Mosaik_Reference_Files for information about building this file\n";
            $missingReqFile = "1";
    }
    if(! -r getConf("PE_ANN"))
    {
        warn "ERROR: Could not read required PE_ANN: ".getConf("PE_ANN")."\n";
            warn "See http://genome.sph.umich.edu/wiki/GotCloud:_Genetic_Reference_and_Resource_Files#Generating_Mosaik_Reference_Files for information about building this file\n";
            $missingReqFile = "1";
    }
}
else
{
    warn "ERROR: Unknown MAP_TYPE, only BWA or MOSAIK is accepted.\n";
    $missingReqFile = "1";
    die "Exiting alignment pipeline due to unknown required setting\n";
}

if($missingReqFile eq "1")
{
    die "Exiting alignment pipeline due to required file(s) missing\n";
}

#--------------------------------------------------------------
#   Read the Index File
#--------------------------------------------------------------
open(IN,$index_file) ||
    die "Unable to open index_file '$index_file': $!\n";

system("mkdir -p $out_dir") &&
    die "Unable to create directory '$out_dir'\n";

my %fq1toFq2 = ();
my %fq1toRg = ();
my %fq1toSm = ();
my %fq1toLib = ();
my %fq1toCn = ();
my %fq1toPl = ();
my %mergeToFq1 = ();

#   Read the first line and check if it is a header or a reference
my $line = <IN>;
chomp($line);
if ($line =~ /^#FASTQ_PREFIX\s*=\s*(.+)\s*$/) {    # Provides reference path to fastq files
    setConf('FASTQ_PREFIX', $1);
    $line = <IN>;
    chomp($line);
}

#   By now the FASTQ directory should be set if it ever will be
my $fq = getConf('FASTQ_PREFIX');
if ((! $fq) || (! -d $fq)) {
#    warn "WARNING: FASTQ directory '$fq' does not exist or -fastq was not specified\n";
}
else {
    #   Make sure there's a trailing / on FASTQ and it is fully qualified
    $fq = abs_path($fq);
    if ($fq !~ /\/$/) { $fq .= '/'; }
    setConf('FASTQ_PREFIX', $fq, 1);       # Force this to be set
}

# Track positions for each field.
my @fields = split('\t', $line);

my $mergeNamePos = -1;
my $fastq1Pos = -1;
my $fastq2Pos = -1;
my $rgidPos = -1;
my $samplePos = -1;
my $libraryPos = -1;
my $centerPos = -1;
my $platformPos = -1;

# loop through the fields.
foreach my $index (0..$#fields)
{
  my $field = uc $fields[$index];
  if($field eq "MERGE_NAME")
  {
    $mergeNamePos = $index;
  }
  elsif ($field eq "FASTQ1")
  {
    $fastq1Pos = $index;
  }
  elsif ($field eq "FASTQ2")
  {
    $fastq2Pos = $index;
  }
  elsif ($field eq "RGID")
  {
    $rgidPos = $index;
  }
  elsif ($field eq "SAMPLE")
  {
    $samplePos = $index;
  }
  elsif ($field eq "LIBRARY")
  {
    $libraryPos = $index;
  }
  elsif ($field eq "CENTER")
  {
    $centerPos = $index;
  }
  elsif ($field eq "PLATFORM")
  {
    $platformPos = $index;
  }
  else
  {
    print "Warning, unknown header field, $field\n";
  }
}

# Verify that mergeName & fastq1 were specified.
if($mergeNamePos == -1)
{
  die "Index File, $index_file, is missing required header field, MERGE_NAME\n";
}
if($fastq1Pos == -1)
{
  die "Index File, $index_file, is missing required header field, FASTQ1\n";
}

#loop through the rest of the file.
while ($line = <IN>)
{
  chomp($line);
  @fields = split('\t', $line);
  $fastq1 = $fields[$fastq1Pos];
  push(@{$mergeToFq1{$fields[$mergeNamePos]}}, $fastq1);
  if($fastq2Pos != -1)
  {
    $fq1toFq2{$fastq1} = $fields[$fastq2Pos];
  }
  else
  {
    $fq1toFq2{$fastq1} = ".";
  }
  if($rgidPos != -1)
  {
    $fq1toRg{$fastq1} = $fields[$rgidPos];
  }
  else
  {
    $fq1toRg{$fastq1} = ".";
  }
  if($samplePos != -1)
  {
    $fq1toSm{$fastq1} = $fields[$samplePos];
  }
  else
  {
    $fq1toSm{$fastq1} = ".";
  }
  if($libraryPos != -1)
  {
    $fq1toLib{$fastq1} = $fields[$libraryPos];
  }
  else
  {
    $fq1toLib{$fastq1} = ".";
  }
  if($centerPos != -1)
  {
    $fq1toCn{$fastq1} = $fields[$centerPos];
  }
  else
  {
    $fq1toCn{$fastq1} = ".";
  }
  if($platformPos != -1)
  {
    $fq1toPl{$fastq1} = $fields[$platformPos];
  }
  else
  {
    $fq1toPl{$fastq1} = ".";
  }
}

# done reading the index file, now process each merge file separately.
my @mkcmds = ();
foreach my $tmpmerge (keys %mergeToFq1)
{
  $mergeName = $tmpmerge;
  # Reset the generic variables
  $allPolish = '';
  $allSteps = '';
  $saiFiles = '';
  $alnFiles = '';
  $polFiles = '';
  $dedupFiles = '';
  $recalFiles = '';

  ####################################################
  #   Create Makefile for this mergeFile
  ####################################################
  # Open the output Makefile for this merge file.
  system("mkdir -p $out_dir/Makefiles") &&
    die "Unable to create directory '$out_dir/Makefiles'\n";
  my $makef = "$out_dir/Makefiles/align_$mergeName.Makefile";
  open(MAK,">$makef") || die "Cannot open $makef for writing.  $!\n";

  print MAK "OUT_DIR=".&getConf("OUT_DIR")."\n";
  print MAK ".DELETE_ON_ERROR:\n\n";

  print MAK "\n";

  #Start
  print MAK "all: \$(OUT_DIR)/$mergeName.OK\n\n";

  print MAK "\$(OUT_DIR)/$mergeName.OK: ".&getConf("FINAL_BAM_DIR")."/$mergeName.recal.bam.done ".&getConf("QC_DIR")."/$mergeName.genoCheck.done " .
    &getConf("QC_DIR")."/$mergeName.qplot.done\n";
  if(! getConf("KEEP_TMP"))
  {
    print MAK "\trm -f \$(SAI_FILES) \$(ALN_FILES) \$(POL_FILES) \$(DEDUP_FILES) \$(RECAL_FILES)\n";
  }
  print MAK "\ttouch \$\@\n\n";

  if($hConf{RUN_VERIFY_BAM_ID} eq "1")
  {
    # Verify Bam ID
    print MAK &getConf("QC_DIR")."/$mergeName.genoCheck.done: ".&getConf("FINAL_BAM_DIR")."/$mergeName.recal.bam.done\n";
    print MAK "\tmkdir -p \$(\@D)\n";
    my $verifyCommand = &getConf("VERIFY_BAM_ID_EXE")." --verbose --vcf ".&getConf("HM3_VCF")." --bam \$(basename \$^) --out \$(basename \$\@) ".&getConf("VERIFY_BAM_ID_OPTIONS")." 2> \$(basename \$\@).log";
    print MAK logCatchFailure("VerifyBamID", $verifyCommand, "\$(basename \$\@).log");
    print MAK "\ttouch \$\@\n\n";
  }

  # If qplot is configured on, run it.
  if($hConf{RUN_QPLOT} eq "1")
  {
    # qplot
    print MAK &getConf("QC_DIR")."/$mergeName.qplot.done: ".&getConf("FINAL_BAM_DIR")."/$mergeName.recal.bam.done\n";
    print MAK "\tmkdir -p \$(\@D)\n";
    my $qplotCommand = &getConf("QPLOT_EXE")." --reference ".&getConf("REF")." --dbsnp ".&getConf("DBSNP_VCF")." --gccontent ".&getConf("REF").".GCcontent " .
        "--stats \$(basename \$\@).stats --Rcode \$(basename \$\@).R --minMapQuality 0 --bamlabel " .
            "$mergeName"."_recal,$mergeName"."_dedup \$(basename \$^) ".&getConf("DEDUP_TMP")."/$mergeName.dedup.bam 2> " .
            "\$(basename \$\@).log";
    print MAK logCatchFailure("QPLOT", $qplotCommand, "\$(basename \$\@).log");
    print MAK "\ttouch \$\@\n\n";
  }

  # Recalibrate the Deduped/Merged BAM
  print MAK &getConf("FINAL_BAM_DIR")."/$mergeName.recal.bam.done: ".&getConf("DEDUP_TMP")."/$mergeName.dedup.bam.done\n";
  print MAK "\tmkdir -p \$(\@D)\n";
  print MAK "\tmkdir -p ".&getConf("RECAL_TMP")."\n";
  if ( !defined($hConf{ALT_RECAB}))
  {
    print MAK logCatchFailure("Recalibration", &getConf("BAM_EXE")." recab --refFile ".&getConf("REF")." --dbsnp ".&getConf("DBSNP_VCF").
        " --storeQualTag OQ --in \$(basename \$^) --out ".&getConf("RECAL_TMP")."/$mergeName.recal.bam ".&getConf("MORE_RECAB_PARAMS")." 2> " .
        "\$(basename \$\@).log", "\$(basename \$\@).log");
  }
  else
  {
    my $newRecab = $hConf{ALT_RECAB};
    eval($newRecab);
  }
  print MAK "\tcp ".&getConf("RECAL_TMP")."/$mergeName.recal.bam \$(basename \$\@)\n";
  print MAK "\t".&getConf("SAMTOOLS_EXE")." index \$(basename \$\@)\n";
  print MAK "\t".&getConf("MD5SUM_EXE")." \$(basename \$\@) > \$(basename \$\@).md5\n";
  print MAK "\ttouch \$\@\n\n";


  # Dedup the Merged BAM
  print MAK &getConf("DEDUP_TMP")."/$mergeName.dedup.bam.done: ".&getConf("MERGE_TMP")."/$mergeName.merged.bam.done\n";
  print MAK "\tmkdir -p \$(\@D)\n";
  if ( !defined($hConf{ALT_DEDUP}))
  {
    print MAK logCatchFailure("Deduping", &getConf("BAM_EXE")." dedup --in \$(basename \$^) --out \$(basename \$\@) " .
        "--log \$(basename \$\@).metrics 2> \$(basename \$\@).err", "\$(basename \$\@).err");
  }
  else
  {
    print MAK "\t$hConf{ALT_DEDUP}\n";
  }
  print MAK "\ttouch \$\@\n\n";

  $dedupFiles .= &getConf("DEDUP_TMP")."/$mergeName.dedup.bam ";
  $recalFiles .= &getConf("RECAL_TMP")."/$mergeName.recal.bam ";

  # get the commands for each fastq that goes into this.
  foreach my $tmpfastq1 (@{$mergeToFq1{$mergeName}})
  {
    $fastq1 = $tmpfastq1;
    $fastq2 = $fq1toFq2{$fastq1};
    $rgid = $fq1toRg{$fastq1};
    $sample = $fq1toSm{$fastq1};
    $library = $fq1toLib{$fastq1};
    $center = $fq1toCn{$fastq1};
    $platform = $fq1toPl{$fastq1};

    # if RGID is specified, add the rg line.
    $rgCommand = '';

    # Perform Mapping.
    # Operate on the fastq pair (or single end if single-ended)
    if(getConf("MAP_TYPE") eq "BWA")
    {
        if ($rgid ne ".") {
            $rgCommand = "-r \"\@RG\tID:$rgid";
            # only add the rg fields if they are specified.
            if ($sample ne ".")   { $rgCommand .= "\tSM:$sample"; }
            if ($library ne ".")  { $rgCommand .= "\tLB:$library"; }
            if ($center ne '.')   { $rgCommand .= "\tCN:$center"; }
            if ($platform ne '.') { $rgCommand .= "\tPL:$platform"; }
            $rgCommand .= '"';
        }
        mapBwa();
    }
    elsif(getConf("MAP_TYPE") eq "MOSAIK")
    {
        if ($rgid ne ".") {
            $rgCommand = "-id $rgid";
            # only add the rg fields if they are specified.
            if ($sample ne ".")   { $rgCommand .= " -sam $sample"; }
            if ($library ne ".")  { $rgCommand .= " -ln $library"; }
            if ($center ne '.')   { $rgCommand .= " -cn $center"; }
            if ($platform ne '.') { $rgCommand .= " -st $platform"; }
        }
        mapMosaik();
    }
  }

  # Maybe rather than using full fastq path in subdirectories, use the merge name?
  # for the first set of subdirs, but what if still not unique?  or does it not matter if we cleanup these files???
  # FOR EXAMPLE, SARDINIA, multiple runs for a sample have the same fastq names, so easiest to keep the subdirs.

  # Merge the Polished BAMs
  print MAK &getConf("MERGE_TMP")."/$mergeName.merged.bam.done: $allPolish\n";
  print MAK "\tmkdir -p \$(\@D)\n";

  my $mergeBams = &getConf("BAM_EXE")." mergeBam --out \$(basename \$\@) \$(subst ".&getConf("POL_TMP").",--in ".&getConf("POL_TMP").",\$(basename \$^))";
  print MAK logCatchFailure("MergingBams", $mergeBams, "\$(basename \$\@).log");
  print MAK "\ttouch \$\@\n\n";

  print MAK $allSteps;

  print MAK "SAI_FILES = $saiFiles\n\n";
  print MAK "ALN_FILES = $alnFiles\n\n";
  print MAK "POL_FILES = $polFiles\n\n";
  print MAK "DEDUP_FILES = $dedupFiles\n\n";
  print MAK "RECAL_FILES = $recalFiles\n";

  close MAK;

  print STDERR "Created $makef\n";

  my $s = "make -f $makef";
  if($opts{numjobspersample})
  {
    $s .= " -j ".$opts{numjobspersample};
  }
  $s .= " > $makef.log";
  push @mkcmds, $s;
}

#--------------------------------------------------------------
#   Makefile created, commands built in @mkcmds
#   Normal case is to run these, either locally or in batch mode
#--------------------------------------------------------------
print STDERR '-' x 69 . "\n";
my @runcmds = ();                   # Build complete commands in here
foreach my $c (@mkcmds) {
    if (! $opts{batchtype} ) { push @runcmds,$c; next; }
    #   Batch command, figure out the complete command
    $c =~ s/\'/\\'/g;                     # Escape single quotes
    my $cmd = $opts{runcluster};
    if ($opts{batchopts}) { $cmd .= " -opts '" . $opts{batchopts} . "'"; }
    $cmd .= ' ' . $opts{batchtype} . " '" . $c . "'";
    push @runcmds,$cmd;
}

if ($opts{'dry-run'}) {
    print STDERR "#  These commands would have been run:\n" .
        '  ' . join("\n  ",@runcmds) . "\n";
    exit;
}

#   We now have an array of commands to run launch and wait for them
print STDERR "Waiting while samples are processed...\n";
my $t = time();
$_ = $Multi::VERBOSE;               # Avoid Perl warning
if ($opts{verbose}) { $Multi::VERBOSE = 1; }
Multi::QueueCommands(\@runcmds, $opts{numconcurrentsamples});
my $errs = Multi::WaitForCommandsToComplete(\&Multi::RunNext);
if ($errs || $opts{verbose}) { print STDERR "###### $errs processes failed ######\n" }
$t = time() - $t;
print STDERR "Processing finished in $t secs";
if ($errs) { print STDERR " WITH ERRORS.  Check the logs\n"; }
else { print STDERR " with no errors reported\n"; }
exit($errs);

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
    $hConf{$key} = $value;
}

#--------------------------------------------------------------
#   loadConf(config)
#
#   Read a configuration file, extracting key=value data
#   Will not return on errors
#--------------------------------------------------------------
sub loadConf {
    my $conf = shift;

    my $curPath = getcwd();
    open(IN,$conf) ||
        die "Unable to read config file '$conf'  CWD=$curPath: $!\n";
    while(<IN>) {
        next if (/^#/ );    # Ignore comments
        next if (/^\s*$/);  # Ignore blank lines
        s/#.*$//;           # Remove in-line comments
        my ($key,$val);
        if ( /^\s*(\w+)\s*=\s*(.*)\s*$/ ) {
            ($key,$val) = ($1,$2);
            $key =~ s/^\s+//;  # remove leading whitespaces
            $key =~ s/\s+$//;  # remove trailing whitespaces
        $val =~ s/^\s+//;
        $val =~ s/\s+$//;
        }
        else {
            die "Unable to parse config line \n" .
                "  File='$conf', line number=" . ($.+1) . "\n" .
                "  Line=$_";
        }
        # Ignore if the key has already been defined
        if (defined($hConf{$key})) {
            if ($opts{verbose}) {
                warn "Key '$key' already defined, ignoring line\n" .
                "  File='$conf', line number=" . ($.+1) . "\n" .
                "  Line=$_";
            }
            next;
        }

        if ( !defined($val) ) { $val = ''; }    # Undefined is null string

        setConf($key, $val);
    }
    close IN;
}

#--------------------------------------------------------------
#   value = getConf(key, required)
#
#   Gets a value in a global hash (%hConf).
#   If required is not TRUE and the key does not exist, return ''
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
#   cmd = logCatchFailure(commandName, command, log)
#
#   Generate a line for a Makefile to generate an error message
#--------------------------------------------------------------
sub logCatchFailure {
    my ($commandName, $command, $log, $failVal) = @_;

    if(!defined $failVal)
    {
        $failVal = 1;
    }

    my $makeCmd = "\t\@echo \"$command\"\n\t\@$command ";
    if($failVal == 1)
    {
        $makeCmd .= "||";
    }
    else
    {
        $makeCmd .= "&&";
    }
    #   What caused the failure.
    $makeCmd .= " (echo \"`grep -i -e abort -e error -e failed $log`\" >&2; ";
    #   Show failed step.
    $makeCmd .= "echo \"\\nFailed $commandName step\" >&2; ";
    #   Copy the log to the failed logs directory.
    $makeCmd .= "mkdir -p \$(OUT_DIR)/failLogs; cp $log \$(OUT_DIR)/failLogs/\$(notdir $log); ";
    #   Show log name to look at.
    $makeCmd .= "echo \"See \$(OUT_DIR)/failLogs/\$\(notdir $log\) for more details\" >&2; ";
    #   Exit on failure.
    $makeCmd .= "exit 1;)\n";
    if (getConf("KEEP_LOG")) { return $makeCmd; }

    #   On success, remove the log
    $makeCmd .= "\trm -f $log\n";
    return $makeCmd;
}

#--------------------------------------------------------------
#   cmd = align(fastq, sai)
#
#   Generate Makefile line for alignment$tmpFastq1
#--------------------------------------------------------------
sub align {
    my ($fastq, $sai) = @_;

    my $alnCmd = &getConf("BWA_EXE")." aln ".&getConf("BWA_QUAL")." ".&getConf("BWA_THREADS")." ".&getConf("REF")." $fastq -f \$(basename \$\@) 2> " .
        "\$(basename \$\@).log";


    my $cmd = &getConf("SAI_TMP")."/".$sai.".done:\n" .
        "\tmkdir -p \$(\@D)\n" .
        logCatchFailure("aln", $alnCmd, "\$(basename \$\@).log") .
        "\ttouch \$\@\n\n";
  return $cmd;
}

#--------------------------------------------------------------
#   cmd = mapBwa()
#
#   Generate Makefile line for a read pair (alignment and polish)
#   Does not seem to return anything, so it must be setting
#   global variables. If so, what? Not obvious what are the ins and outs
#--------------------------------------------------------------
sub mapBwa {
    my $sai1 = $fastq1;
    $sai1 =~ s/fastq.gz$/sai/;
    $sai1 =~ s/fastq$/sai/;
    $saiFiles .= &getConf("SAI_TMP")."/$sai1 ";
    my $saiDone = &getConf("SAI_TMP")."/$sai1.done";

    my $sai2 = $fastq2;
    if ($fastq2 ne ".") {
        $sai2 =~ s/fastq.gz$/sai/;
        $sai2 =~ s/fastq$/sai/;
        $saiFiles .= &getConf("SAI_TMP")."/$sai2 ";
        $saiDone .= " ".&getConf("SAI_TMP")."/$sai2.done";
    }

    my $bam = $sai1;
    $bam =~ s/sai/bam/;
    $alnFiles .= &getConf("ALN_TMP")."/$bam ";
    $polFiles .= &getConf("POL_TMP")."/$bam ";
    $allPolish .= &getConf("POL_TMP")."/$bam.done ";

    #   TODO - maybe check if AS or
    $allSteps .= &getConf("POL_TMP")."/$bam.done: ".&getConf("ALN_TMP")."/$bam.done\n";
    $allSteps .= "\tmkdir -p \$(\@D)\n";

    my $polishCmd = &getConf("BAM_EXE")." polishBam -f ".&getConf("REF")." --AS ".&getConf("AS")." --UR file:".&getConf("REF")." ";
    $polishCmd .= "--checkSQ -i \$(basename \$^) -o \$(basename \$\@) -l \$(basename \$\@).log";
    $allSteps .= logCatchFailure("polishBam", $polishCmd, "\$(basename \$\@).log");
    $allSteps .= "\ttouch \$\@\n\n";

    $allSteps .= &getConf("ALN_TMP")."/$bam.done: $saiDone\n";
    $allSteps .= "\tmkdir -p \$(\@D)\n";

    my $absFastq1 = getAbsPath($fastq1, "FASTQ");
    my $absFastq2 = '';
    if($fastq2 ne ".") {
        $absFastq2 = getAbsPath($fastq2, "FASTQ");
        my $sampeLog = "\$(basename \$(basename \$\@)).sampe.log";
        $allSteps .= "\t(".&getConf("BWA_EXE")." sampe $rgCommand ".&getConf("REF")." \$(basename \$^) $absFastq1 $absFastq2 | " .
            &getConf("SAMTOOLS_EXE")." view -uhS - | ".&getConf("SAMTOOLS_EXE")." sort -m ".&getConf("BWA_MAX_MEM")." - \$(basename \$(basename " .
            "\$\@))) 2> $sampeLog\n";
        $allSteps .= logCatchFailure("sampe", "(grep -q -v -i -e abort -e error -e failed $sampeLog || exit 1)", $sampeLog);
    }
    else {
        my $samseLog = "\$(basename \$(basename \$\@)).samse.log";
        $allSteps .= "\t(".&getConf("BWA_EXE")." samse $rgCommand ".&getConf("REF")." \$(basename \$^) $absFastq1 | " .
            &getConf("SAMTOOLS_EXE")." view -uhS - | ".&getConf("SAMTOOLS_EXE")." sort -m ".&getConf("BWA_MAX_MEM")." - " .
            "\$(basename \$(basename \$\@))) 2> $samseLog\n";
        $allSteps .= logCatchFailure("samse", "(grep -q -v -i -e abort -e error -e failed $samseLog || exit 1)", $samseLog);
    }
    $allSteps .= "\ttouch \$\@\n\n";

    $allSteps .= align($absFastq1, $sai1);
    if($fastq2 ne ".") {
        $allSteps .= align($absFastq2, $sai2);
    }
}

#--------------------------------------------------------------
#   cmd = mapMosaik()
#
#   Generate Makefile line for a read pair (alignment and polish)
#   Does not seem to return anything, so it must be setting
#   global variables. If so, what? Not obvious what are the ins and outs
#--------------------------------------------------------------
sub mapMosaik {

  my $absFastq1 = getAbsPath($fastq1, "FASTQ");
  my $absFastq2 = '';
  if($fastq2 ne ".")
  {
    $absFastq2 = getAbsPath($fastq2, "FASTQ");
  }

  my $mkb = $fastq1;
  $mkb =~ s/fastq.gz$/mkb/;
  $mkb =~ s/fastq$/mkb/;
  my $mkbFiles .= &getConf("MKB_TMP")."/$mkb ";
  my $mosaikBuildDone = &getConf("MKB_TMP")."/$mkb.done";

  my $bam = $mkb;
  $bam =~ s/mkb/bam/;
  $alnFiles .= &getConf("ALN_TMP")."/$bam ";
  $polFiles .= &getConf("POL_TMP")."/$bam ";
  $allPolish .= &getConf("POL_TMP")."/$bam.done ";
  my $alignDone = &getConf("ALN_TMP")."/$bam.done";
  my $sortDone = $alignDone;
  $sortDone =~ s/.bam.done/.sort.bam.done/;

  #############
  # Polish the bam.  Depends on the sorted bam.
  $allSteps .= &getConf("POL_TMP")."/$bam.done: $sortDone\n";
  $allSteps .= "\tmkdir -p \$(\@D)\n";

  my $polishCmd = &getConf("BAM_EXE")." polishBam -f ".&getConf("REF")." --AS ".&getConf("AS")." --UR file:".&getConf("REF")." ";
  $polishCmd .= "--checkSQ -i \$(basename \$^) -o \$(basename \$\@) -l \$(basename \$\@).log";
  $allSteps .= logCatchFailure("polishBam", $polishCmd, "\$(basename \$\@).log");
  $allSteps .= "\ttouch \$\@\n\n";

  #############
  # Sort the bam.  Depends on the aligned bam.
  $allSteps .= "$sortDone: $alignDone\n";
  $allSteps .= "\tmkdir -p \$(\@D)\n";

  my $sortPrefix = "\$(basename \$(basename \$\@))";
  my $sortcmd = &getConf("SAMTOOLS_EXE")." sort -m ".&getConf("BWA_MAX_MEM")." \$(basename \$^) $sortPrefix 2> $sortPrefix.log";
  $allSteps .= "\t$sortcmd\n";
  $allSteps .= logCatchFailure("sort", "(grep -q -i -e abort -e error -e failed $sortPrefix.log; [ \$\$? -eq 1 ])", "$sortPrefix.log");
  $allSteps .= "\ttouch \$\@\n\n";


  #############
  # Run MosaikAlign to create the bam.  Depends on the Mosaik Build step.
  $allSteps .= "$alignDone: $mosaikBuildDone\n";
  $allSteps .= "\tmkdir -p \$(\@D)\n";

  my $mosaikRef = getConf("REF");
  $mosaikRef =~ s/\.[^.]+$/.dat/g;                     # Escape single quotes
  my $mosaikJmp = $mosaikRef;
  $mosaikJmp =~ s/\.dat$/_15/;

  my $mosaikAlign = &getConf("MOSAIK_ALIGN_EXE")." ".getConf("MOSAIK_THREADS")." -in \$(basename \$\^) -ia $mosaikRef -j $mosaikJmp -annse ".getConf("SE_ANN")." -annpe ".getConf("PE_ANN")." -out \$(basename \$(basename \$\@)) -hs 15 > \$(basename \$\@).log";
  $allSteps .= logCatchFailure("mosaikAlign", $mosaikAlign, "\$(basename \$\@).log");
  $allSteps .= "\ttouch \$\@\n\n";

  #############
  # Run MosaikBuild to create the intermediate file (no dependencies).
  $allSteps .= "$mosaikBuildDone:\n";
  $allSteps .= "\tmkdir -p \$(\@D)\n";
  my $mosaikBuild = &getConf("MOSAIK_BUILD_EXE")." -q $absFastq1 ";
  if($fastq2 ne ".")
  {
    $mosaikBuild .= "-q2 $absFastq2 ";
  }
  $mosaikBuild .= "-st illumina -out \$(basename \$\@) $rgCommand > \$(basename \$\@).log";
  $allSteps .= logCatchFailure("mosaikBuild", $mosaikBuild, "\$(basename \$\@).log");
  $allSteps .= "\ttouch \$\@\n\n";
}
   
#--------------------------------------------------------------
#   value = getAbsPath(file, type)
#
#   Get the absolute path for the specified file.
#   Heirachy for determining absolute path from a relative path:
#      1) Based on Type:
#          a) FASTQ: FASTQ_PREFIX
#      2) Based on BASE_PREFIX (if <TYPE>_PREFIX is not set)
#      3) Relative to the current working directory,
#--------------------------------------------------------------
sub getAbsPath {
    my ($file, $type) = @_;

    # Check if the path is already absolute
    if ( ($file =~ /^\//) )
    {
        return($file);
    }

    # Relative path.
    my $newPath = "";

    # Check if type was set.
    if( defined($type) && ($type ne "") )
    {
        # Check if a directory was defined for this type.
        my $val1 = &getConf($type."_PREFIX");
        if( defined($val1) && ($val1 ne "") )
        {
            $newPath = "$val1/$file";
        }
    }

    if($newPath eq "")
    {
        # Type specific directory is not set,
        # so check if BASE_PREFIX is set.
        my $val = getConf("BASE_PREFIX");
        if( defined($val) && ($val ne "") )
        {
            $newPath = "$val/$file";
        }
    }
    if($newPath eq "")
    {
        $newPath = $file;
    }

    # Convert to absolute path
    my $fullPath = abs_path($newPath);
    if( !defined($fullPath) || ($fullPath eq '') )
    {
        if( ($newPath =~ /^\//) )
        {
            die("ERROR: Could not find $newPath\n");
        }
        die("ERROR: Could not find $newPath in ".getcwd()."\n");
    }
    return($fullPath);
}

#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

align.pl - Convert FASTQs to BAMs

=head1 SYNOPSIS

  align.pl -test ~/testaligner    # Run short self check
  align.pl -conf ~/mydata.conf -out ~/testdir
  align.pl -batchtype slurm -conf ~/mydata.conf -index ~/mydata.index
  align.pl -conf ~/mydata.conf -index ~/mydata.index -ref /usr/local/ref


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

  INDEX_FILE = indexFile.txt
  # References
  REF_DIR = /gotcloud/test/align/chr20Ref
  AS = NCBI37
  REF = $(REF_DIR)/human_g1k_v37_chr20.fa
  DBSNP_VCF =  $(REF_DIR)/dbsnp.b130.ncbi37.chr20.vcf.gz
  HM3_VCF = $(REF_DIR)/hapmap_3.3.b37.sites.vcf.gz

The B<index file> file specifies information about individuals and paths to
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

=item B<-batchopts  options_string>

Specifies options to be passed to the batch engine.
You almost always will need to quote I<options_string>.
This is only valid if B<batchtype> is specified.

=item B<-batchtype local | slurm | sge | pbs | flux>

Specifies the batch system to be used when executing the commands.
These determine exactly how B<runcluster> will run the command.
the type 'flux' is an alias for 'pbs'.
The default is B<local>.

=item B<-conf file>

Specifies the configuration file to be used.
The default configuration is B<gotcloudDefaults.conf> found in the same directory
where this program resides.
If this file is not found, you must specify this option on the command line.

=item B<-dry-run>

If specified no commands will actually be executed, but you will be shown
the commands that would be run.

=item B<-fastq_prefix dir>

This specifies a directory prefix which should be added to the paths in the index file.
This file contains a path to a fastq file.
This path can be relative to the current working directory or a fully-qualified path.
If it is relative, then with the B<fastq_prefix> option, you can add a directory
name to this relative path.

=item B<-help>

Generates this output.

=item B<-index_file str>

Specifies the name of the index file containing the table of fastqs to process.
This value must be set in the configuration file or specified by this option.

=item B<-keeplog>

If specified, the log files used in this process will not be deleted.
The default is to remove the log files.

=item B<-keeptmp>

If specified, the temporary files used in this process will not be deleted.
The default is to remove the temporary files.

=item B<-nowait>

Do not wait for the tasks that were submitted to the cluster to end.
This is forced when B<batchtype pbs> is specified.

=item B<-numconcurrentsamples N>

Specifies the number of samples to be processed concurrently.
This effectively defaults to '2'.
The number of processesors to be used at the same time on the local machine
or on the cluster is I<-numconcurrentsamples> times I<-numjobspersample>.

=item B<-numjobspersample N>

Specifies the number of jobs to run per sample. In practice this is
the value of the B<-j> flag for the make command.
This effectively defaults to '1'.
If not specified, the flag is not set on the make command to be executed.
The number of processesors to be used at the same time on the local machine
or on the cluster is I<-numconcurrentsamples> times I<-numjobspersample>.

=item B<-out_dir dir>

Specifies the toplevel directory where the output is created.

=item B<-ref_dir dir>

Specifies the location of the reference files.
The default is B</usr/local/gotcloud.ref> but will depend completely
on where you got the reference files and where they were installed.
This value must be set in the configuration file or specified by this option.

=item B<-runcluster path>

Specifies the path to the script which is called to invoke the command to be run
in batch mode.
This defaults to B<../scripts/runcluster.pl>, relative to where this script is installed.
This script expects the first parameter to be B<batchtype>, followed by the
command to be executed.

=item B<-test out_dir>

Run a small test case putting the output in the directory B<out_dir> and verify the output.

=item B<-verbose>

Specifies that additional details are to be printed out.

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
