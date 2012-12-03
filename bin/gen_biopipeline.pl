#!/usr/bin/perl
#################################################################
#
# Name:	gen_biopipeline.pl
#
# Description:
#   Use this to generate makefiles for a single session whatever it is.
#
# ChangeLog:
#   13 Aug 2012 tpg   Initial coding
#   18 Oct 2012 mkt   Update to use index
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
my @keys = ();

#############################################################################
## getAbsolutePath() : return the absolute path.
############################################################################
sub getAbsolutePath
{
  my $updatedPath = shift;

  unless ( $updatedPath =~ /^\// ) {
    $updatedPath = getcwd()."/".$updatedPath;
  }
  return $updatedPath;
}


sub setConf
{
  my $key = shift;
  my $val = shift;

  if ( !defined($hConf{$key}))
  {
     push (@keys, $key);
  }

  $hConf{$key} = $val;
}

#############################################################################
## loadConf() : load configuration file and build hash table for configuration
############################################################################
sub loadConf {
    my $conf = shift;

    my $curPath = getcwd();

    open(IN,$conf) || die "Cannot open $conf file for reading, from $curPath";
    while(<IN>) {
	next if ( /^#/ );  # if the line starts with #, regard them as comment line
	s/#.*$//;          # trim in-line comment lines starting with #
	my ($key,$val);
	if ( /^([^=]+)=(.*)$/ ) {
	    ($key,$val) = ($1,$2);
	}
	else {
	    die "Cannot parse line $_ at line $. in $conf\n";
	}

	$key =~ s/^\s+//;  # remove leading whitespaces
	$key =~ s/\s+$//;  # remove trailing whitespaces

        # Skip if the key has already been defined.
        next if ( defined($hConf{$key}) );

	if ( !defined($val) ) {
	    $val = "";     # if value is undefined, set it as empty string
	}
	else {
	    $val =~ s/^\s+//;
	    $val =~ s/\s+$//;
	}

	setConf($key, $val);
    }
    close IN;
}

#############################################################################
## getConf() : access configuration hash table to contain a value
############################################################################
sub getConf {
    my $key = shift;

    if ( defined($hConf{$key}) ) {
        my $val = $hConf{$key};
	# check if predefined key exist and substitute it if needed
	while ( $val =~ /\$\((\S+)\)/ ) {
	    my $subkey = $1;
	    my $subval = &getConf($subkey);
	    if ($subval eq "") {
		die "Cannot parse configuration value $val, $subkey not previously defined\n";
            }
            $val =~ s/\$\($subkey\)/$subval/;
	}
	return $val;
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

my $allPolish = "";
my $allSteps = "";
my $saiFiles = "";
my $alnFiles = "";
my $polFiles = "";
my $dedupFiles = "";
my $recalFiles = "";

my $keepLog = "0";

#############################################################################
## Subroutine for catching & logging failures
############################################################################
sub logCatchFailure
{
  my $commandName = shift;
  my $command = shift;
  my $log = shift;

  my $makeCmd = "\t\@echo \"$command\"\n";
  $makeCmd .= "\t\@$command || ";
  # print what caused the failure.
  $makeCmd .= "(echo \"`grep -i -e abort -e error -e failed $log`\" >&2; ";
  # print the failed step.
  $makeCmd .= "echo \"\\nFailed $commandName step\" >&2; ";
  # Copy the log to the failed logs directory.
  $makeCmd .= "mkdir -p \$(OUT_DIR)/failLogs; cp $log \$(OUT_DIR)/failLogs/\$(notdir $log); ";
  # Print the log name to look at.
  $makeCmd .= "echo \"See \$(OUT_DIR)/failLogs/\$\(notdir $log\) for more details\" >&2; ";
  # exit on failure.
  $makeCmd .= "exit 1;)\n";
  if($keepLog eq "0")
  {
    # On success, remove the log.
    $makeCmd .= "\trm -f $log\n";
  }
  
  return $makeCmd;
}


#############################################################################
## Alignment Subroutine
############################################################################
sub align {
  my $fastq = shift;
  my $sai = shift;
  my $alnCmd = "\$(BWA_EXE) aln \$(BWA_QUAL) \$(BWA_THREADS) \$(FA_REF) $fastq -f \$(basename \$\@) 2> \$(basename \$\@).log";

  my $cmd = "\$(SAI_TMP)/".$sai.".done:\n";
  $cmd .= "\tmkdir -p \$(\@D)\n";
  $cmd .= logCatchFailure("aln", $alnCmd, "\$(basename \$\@).log");
  $cmd .= "\ttouch \$\@\n\n";
  return $cmd;
}

#############################################################################
## Subroutine to generate commands for a Read Pair (Alignment & Polish)
############################################################################
sub pair_cmds
{
  my $sai1 = $fastq1;
  $sai1 =~ s/fastq.gz$/sai/;
  $sai1 =~ s/fastq$/sai/;
  $saiFiles .= "\$(SAI_TMP)/$sai1 ";
  my $saiDone = "\$(SAI_TMP)/$sai1.done";

  my $sai2 = $fastq2;
  if($fastq2 ne ".")
  {
    $sai2 =~ s/fastq.gz$/sai/;
    $sai2 =~ s/fastq$/sai/;
    $saiFiles .= "\$(SAI_TMP)/$sai2 ";
    $saiDone .= " \$(SAI_TMP)/$sai2.done";
 }

  my $bam = $sai1;
  $bam =~ s/sai/bam/;

  $alnFiles .= "\$(ALN_TMP)/$bam ";
  $polFiles .= "\$(POL_TMP)/$bam ";

  $allPolish .= "\$(POL_TMP)/$bam.done ";

#TODO - maybe check if AS or 

  $allSteps .= "\$(POL_TMP)/$bam.done: \$(ALN_TMP)/$bam.done\n";
  $allSteps .= "\tmkdir -p \$(\@D)\n";

  my $polishCmd = "\$(BAM_EXE) polishBam -f \$(FA_REF) --AS \$(AS) --UR file:\$(FA_REF) ";
  $polishCmd .= "--checkSQ -i \$(basename \$^) -o \$(basename \$\@) -l \$(basename \$\@).log";
  $allSteps .= logCatchFailure("polishBam", $polishCmd, "\$(basename \$\@).log");
  $allSteps .= "\ttouch \$\@\n\n";

  $allSteps .= "\$(ALN_TMP)/".$bam.".done: $saiDone\n";
  $allSteps .= "\tmkdir -p \$(\@D)\n";

  my $tmpFastq1 = &getConf("FASTQ") . $fastq1;
  my $absFastq1 = getAbsolutePath($tmpFastq1);
  my $absFastq2 = "";
  if($fastq2 ne ".")
  {
    my $tmpFastq2 = &getConf("FASTQ") . $fastq2;
    $absFastq2 = getAbsolutePath($tmpFastq2);
    my $sampeLog = "\$(basename \$(basename \$\@)).sampe.log";
    $allSteps .= "\t(\$(BWA_EXE) sampe $rgCommand \$(FA_REF) \$(basename \$^) $absFastq1 $absFastq2 | \$(SAMTOOLS_EXE) view -uhS - | \$(SAMTOOLS_EXE) sort -m \$(BWA_MAX_MEM) - \$(basename \$(basename \$\@))) 2> $sampeLog\n";
    $allSteps .= logCatchFailure("sampe", "(grep -q -v -i -e abort -e error -e failed $sampeLog || exit 1)", $sampeLog);
  }
  else
  {
    my $samseLog = "\$(basename \$(basename \$\@)).samse.log";
    $allSteps .= "\t(\$(BWA_EXE) samse $rgCommand \$(FA_REF) \$(basename \$^) $absFastq1 | \$(SAMTOOLS_EXE) view -uhS - | \$(SAMTOOLS_EXE) sort -m \$(BWA_MAX_MEM) - \$(basename \$(basename \$\@))) 2> $samseLog\n";
    $allSteps .= logCatchFailure("samse", "(grep -q -v -i -e abort -e error -e failed $samseLog || exit 1)", $samseLog);
  }
  $allSteps .= "\ttouch \$\@\n\n";

  $allSteps .= align($absFastq1, $sai1);
  if($fastq2 ne ".")
  {
    $allSteps .= align($absFastq2, $sai2);
  }
}


#############################################################################
## Main processing
############################################################################
my($me, $scriptPath, $mesuffix) = fileparse($0, '\.pl');
my $scriptDir = abs_path($scriptPath);
$scriptDir =~ /(.*)\/bin$/;
my $basepath = $1;
setConf("PIPELINE_DIR", $basepath);

(my $version = '$Revision: 1.1 $ ') =~ tr/[0-9].//cd;

#--------------------------------------------------------------
#   Initialization - Sort out the options and parameters
#--------------------------------------------------------------
my %opts = (
);
Getopt::Long::GetOptions( \%opts,qw(
    help
    test=s
    out_dir=s
    conf=s
    index_file=s
    ref_dir=s
    fastq=s
    keepTmp
    keepLog
    numjobs=i
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

my $here = getcwd();                # Where I am now
if ($opts {test})
{
  my $testdir=$opts{test};
  if (substr($testdir, 0, 1) ne '/')
  {
    $testdir = $here . '/' . $opts{test};
  }
  `mkdir -p $testdir`;
  print "Running GOTCLOUD TEST, test log in: $testdir/biopipeTest.log\n";
  system("make -C ${basepath}/test/align BASE_DIR=${basepath} BIOPIPE_TEST_DIR=$testdir") && die "Failed test";
  print "Test Passed\n";
  exit 1;
}

####################################################
# load configuration
####################################################
# Check if out_dir was specified on the command line prior
# to reading defaults.
my $out_dir = "";
if ($opts{out_dir})
{
  $out_dir = getAbsolutePath($opts{out_dir});
  setConf("OUT_DIR", $out_dir);
}

my $ref_dir = "";
if ($opts{ref_dir})
{
  $ref_dir = getAbsolutePath($opts{ref_dir});
  setConf("REF_DIR", $ref_dir);
}

my $fastq = "";
if ($opts{fastq})
{
  $fastq = getAbsolutePath($opts{fastq});
  setConf("FASTQ", $fastq);
}

# Check if index_file was specified on the command line prior
# to reading defaults.
my $index_file = "";
if ($opts{index_file})
{
  $index_file = getAbsolutePath($opts{index_file});
  setConf("INDEX_FILE", $index_file);
}

my $keepTmp = "0";
if($opts{keepTmp})
{
  $keepTmp = "1";
}
setConf("KEEP_TMP", $keepTmp);

$keepLog = "0";
if($opts{keepLog})
{
  $keepLog = "1";
}
setConf("KEEP_LOG", $keepLog);

# Load the user specified configuration if there was one.
if ($opts{conf})
{
  if (! -r $opts{conf})   { die "Option '$opts{conf}' does not exist\n"; }
  &loadConf($opts{conf});
}

# Ensure the output directory was specified.
$out_dir = &getConf("OUT_DIR");
if($out_dir eq "") { die "Neither '--out_dir' nor a '--conf' file with 'OUT_DIR' were provided\n"; }

# Adjust the output directory to absolute.
$out_dir = getAbsolutePath($out_dir);
setConf("OUT_DIR", $out_dir);

$ref_dir = &getConf("REF_DIR");
if($ref_dir ne "")
{
  # Adjust the reference directory to absolute.
  $ref_dir = getAbsolutePath($ref_dir);
  setConf("REF_DIR", $ref_dir);
}

# get the fastq prefix if there is one.
$fastq = &getConf("FASTQ");
if($fastq ne "")
{
  # Adjust the fastq prefix to absolute.
  $fastq = getAbsolutePath($fastq) . "/";
  setConf("FASTQ", $fastq);
}

# Ensure the index file was specified
$index_file = &getConf("INDEX_FILE");
if($index_file eq "") { die "Neither '--index_file' nor a '--conf' file with 'INDEX_FILE' were provided\n"; }

# Adjust the index file path to be absolute.
$index_file = getAbsolutePath($index_file);
setConf("INDEX_FILE", $index_file);

# Load the DEFAULT configuration.
&loadConf($scriptPath."/pipelineDefaults.conf");

$keepTmp = &getConf("KEEP_TMP");
$keepLog = &getConf("KEEP_LOG");


####################################################
# Read the Index File
####################################################
open(IN,$index_file) ||
    die "Unable to open index_file $index_file: $!\n";

`mkdir --p $out_dir`;

my %fq1toFq2 = ();
my %fq1toRg = ();
my %fq1toSm = ();
my %fq1toLib = ();
my %fq1toCn = ();
my %fq1toPl = ();
my %mergeToFq1 = ();


# read the first line and check if it is a header.
my $line = <IN>;
chomp($line);
my @fields = split('\t', $line);

# Track positions for each field.
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


my $mkcmds = "";

# done reading the index file, now process each merge file separately.
foreach my $tmpmerge (keys %mergeToFq1)
{
  $mergeName = $tmpmerge;
  # Reset the generic variables
  $allPolish = "";
  $allSteps = "";
  $saiFiles = "";
  $alnFiles = "";
  $polFiles = "";
  $dedupFiles = "";
  $recalFiles = "";

  ####################################################
  #   Create Makefile for this mergeFile
  ####################################################
  # Open the output Makefile for this merge file.
  `mkdir --p $out_dir/Makefiles`;
  my $makef = "$out_dir/Makefiles/biopipe_$mergeName.Makefile";
  open(MAK,">$makef") || die "Cannot open $makef for writing.\n";

  print MAK ".DELETE_ON_ERROR:\n\n";

  # Write the values from the configuration.
  foreach my $key (@keys)
  {
    print MAK "$key = $hConf{$key}\n";
  }

  print MAK "\n";

  #Start
  print MAK "all: \$(OUT_DIR)/$mergeName.OK\n\n";

  print MAK "\$(OUT_DIR)/$mergeName.OK: \$(RECAL_DIR)/$mergeName.recal.bam.done \$(QC_DIR)/$mergeName.genoCheck.done \$(QC_DIR)/$mergeName.qplot.done\n";
  if($keepTmp eq "0")
  {
    print MAK "\trm -f \$(SAI_FILES) \$(ALN_FILES) \$(POL_FILES) \$(DEDUP_FILES) \$(RECAL_FILES)\n";
  }
  print MAK "\ttouch \$\@\n\n";

  if($hConf{RUN_VERIFY_BAM_ID} eq "1")
  {
    # Verify Bam ID
    print MAK "\$(QC_DIR)/$mergeName.genoCheck.done: \$(RECAL_DIR)/$mergeName.recal.bam.done\n";
    print MAK "\tmkdir -p \$(\@D)\n";
    my $verifyCommand = "\$(VERIFY_BAM_ID_EXE) --reference \$(FA_REF) -v -m 10 -g 5e-3 --selfonly -d 50 -b \$(PLINK) --in \$(basename \$^) --out \$(basename \$\@) 2> \$(basename \$\@).log";
    print MAK logCatchFailure("VerifyBamID", $verifyCommand, "\$(basename \$\@).log");
    print MAK "\ttouch \$\@\n\n";
  }

  # If qplot is configured on, run it.
  if($hConf{RUN_QPLOT} eq "1")
  {
    # qplot
    print MAK "\$(QC_DIR)/$mergeName.qplot.done: \$(RECAL_DIR)/$mergeName.recal.bam.done\n";
    print MAK "\tmkdir -p \$(\@D)\n";
    my $qplotCommand = "\$(QPLOT_EXE) --reference \$(FA_REF) --dbsnp \$(DBSNP_VCF) --gccontent \$(FA_REF).GCcontent --stats \$(basename \$\@).stats --Rcode \$(basename \$\@).R --minMapQuality 0 --bamlabel $mergeName"."_recal,$mergeName"."_dedup \$(basename \$^) \$(DEDUP_TMP)/$mergeName.dedup.bam 2> \$(basename \$\@).log";
    print MAK logCatchFailure("QPLOT", $qplotCommand, "\$(basename \$\@).log");
    print MAK "\ttouch \$\@\n\n";
  }

  # Recalibrate the Deduped/Merged BAM
  print MAK "\$(RECAL_DIR)/$mergeName.recal.bam.done: \$(DEDUP_TMP)/$mergeName.dedup.bam.done\n";
  print MAK "\tmkdir -p \$(\@D)\n";
  print MAK "\tmkdir -p \$(RECAL_TMP)\n";
  if ( !defined($hConf{ALT_RECAB}))
  {
    print MAK logCatchFailure("Recalibration", "\$(BAM_EXE) recab --refFile \$(FA_REF) --dbsnp \$(DBSNP_VCF) --storeQualTag OQ --in \$(basename \$^) --out \$(RECAL_TMP)/$mergeName.recal.bam \$(MORE_RECAB_PARAMS) 2> \$(basename \$\@).log", "\$(basename \$\@).log");
  }
  else
  {
    my $newRecab = $hConf{ALT_RECAB};
    eval($newRecab);
  }
  print MAK "\tcp \$(RECAL_TMP)/$mergeName.recal.bam \$(basename \$\@)\n";
  print MAK "\t\$(SAMTOOLS_EXE) index \$(basename \$\@)\n";
  print MAK "\t\$(MD5SUM_EXE) \$(basename \$\@) > \$(basename \$\@).md5\n";
  print MAK "\ttouch \$\@\n\n";


  # Dedup the Merged BAM
  print MAK "\$(DEDUP_TMP)/$mergeName.dedup.bam.done: \$(MERGE_TMP)/$mergeName.merged.bam.done\n";
print MAK "\tmkdir -p \$(\@D)\n";
  if ( !defined($hConf{ALT_DEDUP}))
  {
    print MAK logCatchFailure("Deduping", "\$(BAM_EXE) dedup --in \$(basename \$^) --out \$(basename \$\@) --log \$(basename \$\@).metrics 2> \$(basename \$\@).err", "\$(basename \$\@).err");
  }
  else
  {
    print MAK "\t$hConf{ALT_DEDUP}\n";
  }
  print MAK "\ttouch \$\@\n\n";

  $dedupFiles .= "\$(DEDUP_TMP)/$mergeName.dedup.bam ";
  $recalFiles .= "\$(RECAL_TMP)/$mergeName.recal.bam ";

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
    $rgCommand = "";
    if($rgid ne ".")
    {
      $rgCommand = "-r \"\@RG\tID:$rgid";
      # only add the rg fields if they are specified.
      if($sample ne ".")
      {
        $rgCommand .= "\tSM:$sample";
      }
      if($library ne ".")
      {
        $rgCommand .= "\tLB:$library";
      }
      if($center ne ".")
      {
        $rgCommand .= "\tCN:$center";
      }
      if($platform ne ".")
      {
        $rgCommand .= "\tPL:$platform";
      }
      $rgCommand .= "\"";
    }
    
    ###########################
    # Operate on the fastq pair (or single end if single-ended)
    pair_cmds();
  }

#Maybe rather than using full fastq path in subdirectories, use the merge name? for the first set of subdirs, but what if still not unique?  or does it not matter if we cleanup these files???  FOR EXAMPLE, SARDINIA, multiple runs for a sample have the same fastq names, so easiest to keep the subdirs.

  # Merge the Polished BAMs
  print MAK "\$(MERGE_TMP)/$mergeName.merged.bam.done: $allPolish\n";
  print MAK "\tmkdir -p \$(\@D)\n";
  print MAK "\t\$(JAVA_EXE) -jar \$(JAVA_MEM) \$(MERGE_JAR) VALIDATION_STRINGENCY=SILENT AS=true O=\$(basename \$\@) \$(subst \$(POL_TMP),I=\$(POL_TMP),\$(basename \$^))\n";
  print MAK "\ttouch \$\@\n\n";

  print MAK $allSteps;

  print MAK "SAI_FILES = $saiFiles\n\n";
  print MAK "ALN_FILES = $alnFiles\n\n";
  print MAK "POL_FILES = $polFiles\n\n";
  print MAK "DEDUP_FILES = $dedupFiles\n\n";
  print MAK "RECAL_FILES = $recalFiles\n";

  close MAK;

  print STDERR "Finished creating makefile $makef\n";

  $mkcmds .= "make -f $makef";
  if($opts{numjobs})
  {
    $mkcmds .= " -j ".$opts{numjobs};
    #  system($cmd) &&
    #    die "Makefile, $makef failed d=$cmd\n";
  }
  $mkcmds .= " > $makef.log\n";
}

print STDERR "--------------------------------------------------------------------\n";

print STDOUT "Run the following commands:\n\n";

print STDOUT "$mkcmds\n";

exit;


#==================================================================
#   Perldoc Documentation
#==================================================================
__END__

=head1 NAME

gen_biopipeline.pl - Convert FASTQs to BAMs

=head1 SYNOPSIS

	gen_biopipeline.pl

=head1 DESCRIPTION

Use this program to generate a Makefile which will run the programs
to convert one or more FASTQ files to a single BAM file.

=head1 OPTIONS

=over 4

=item B<-help>

Generates this output.

=item B<-out_dir dir>

Specifies the toplevel directory where the output is created.

=item B<-index_file str>

Specifies the name of the index file containing the table of fastqs to process.

=item B<-numjobs>

Number of jobs to run when invoking the Makefile.  By default, it is 0
and will simply tell you how to run the Makefile, but will not run it.

=back

=head1 EXIT

If no fatal errors are detected, the program exits with a
return code of 0. Any error will set a non-zero return code.

=head1 AUTHOR

Written by Mary Kate Trost I<E<lt>mktrost@umich.eduE<gt>>.
This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; See http://www.gnu.org/copyleft/gpl.html

=cut
