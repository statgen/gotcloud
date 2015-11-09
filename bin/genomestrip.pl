#!/usr/bin/env perl

use strict;
use POSIX qw(exp log pow log10);
use warnings;
use File::Path qw(make_path);
use File::Basename;
use Cwd;
use Cwd 'abs_path';
use FindBin;
use lib "$FindBin::Bin/";
use hyunlib qw(forkExecWait initRef %hszchrs @achrs batchCmd xargsCmd mosixCmd joinps getAbsPath getIntConf loadConf dumpConf setConf getConf ReadConfig parseKeyVal);
use gcGetOptions qw(gcpod2usage gcGetOptions gcstatus);

# Set the umake base directory.

$_ = abs_path($0);
my($scriptName, $scriptPath) = fileparse($_);
my $scriptDir = abs_path($scriptPath);
my $gotcloudRoot = $scriptDir;
if ($scriptDir =~ /(.*)\/bin/) { $gotcloudRoot = $1;}
push @INC,"$gotcloudRoot/bin";                  # Use lib is a BEGIN block and does not work

my $runMetadata = "";
my $runDiscovery = "";
my $runThirdparty = "";
my $runGenotype = "";
my $outdir = "";
my $out = "";
my $outMetadata = "";
my $outDiscovery = "";
my $outThirdparty = "";
my $outGenotype = "";
my $region = "";
my $unit = 100;
my $conf = "";
my $invcf = "";

my $gcroot = "";
my $listf = ""; ## BAM list file
my $gsdir = ""; #"$gotcloudRoot/svtoolkit"; ## latest version (1.04.1418)
my $tmpdir = ""; ## temporary directory
my $mosixopts = ""; ## options for mosix runs
my $paramf = ""; #"$gsdir/conf/genstrip_parameters.txt";
my $refdir = ""; #"$gsdir/ref";
my $ref = ""; #refdir/hs37d5.fa";
my $maskf = ""; #$refdir/compiledgenomemask.hs37d5.fa";
my $mapf = ""; #"$gsdir/conf/humgen_g1k_v37_ploidy.map";

my $pass = "";

my $minimumSize = 100;
my $maximumSize = 1000000;
my $windowSize = 2000000;
my $windowPadding = 10000;
my $rcWindowSize = 10000000;

my $baseprefix = '';
my $bamprefix = '';
my $refprefix = '';
my $noPhoneHome = '';
my $makebasename = "";
my $verbose = "";
my $autosomes = "";

my $dryrun = "";
my $numjobs = 1;

my $skiprc = "";

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
gcGetOptions(
    "-GotCloud Structural Variation Pipeline through GenomeSTRiP",
    "--Command options",
    "run-metadata" => [\$runMetadata, "Create metadata", "GENOMESTRIP_RUN_METADATA"],
    "run-discovery" => [\$runDiscovery, "Run variant discovery and filtering. Can run with --run-metadata together", "GENOMESTRIP_RUN_DISCOVERY"],
    "run-genotype" => [\$runGenotype, "Run genotyping - requires to finish run-metadata and run-discovery", "GENOMESTRIP_RUN_GENOTYPE"],
    "run-thirdparty" => [\$runThirdparty, "Run genotyping and filtering of third-party sites", "GENOMESTRIP_RUN_THIRDPARTY"],

    "--Options for input/output data",
    "gotcloudroot|gcroot=s" => [\$gcroot, "GotCloud Root Directory", "GOTCLOUD_ROOT"],
    "conf=s" => [\$conf, "GotCloud configuration files"],
    "outdir=s" => [\$outdir, "Override's conf file's OUT_DIR.  Used as the genomestrip output directory unless --out or GENOMESTRIP_OUT is set", "OUT_DIR"],    
    "list=s" => [\$listf, "BAM list file containing ID and BAM path", "BAM_LIST"],
    "out=s" => [\$out, "Output directory which stores subdirectories such as metadata/, discovery/, genotypes/, thirdparty/ unless overriden individually", "GENOMESTRIP_OUT"],
    "metadata=s", [\$outMetadata,"Output directory to store --run-metadata results. Default is [OUT]/metadata/", "GENOMESTRIP_METADATA"],
    "discovery=s", [\$outDiscovery,"Output directory to store --run-discovery results. Default is [OUT]/discovery/", "GENOMESTRIP_DISCOVERY"],
    "genotype=s", [\$outDiscovery,"Output directory to store --run-genotype results. Default is [OUT]/genotype/", "GENOMESTRIP_GENOTYPE"],
    "thirdparty=s", [\$outDiscovery,"Output directory to store --run-thirdparty results. Default is [OUT]/thirdparty/", "GENOMESTRIP_THIRDPARTY"],
    "--Advanced Options",
    "tmp-dir=s" => [\$tmpdir, "temporary directory to store temporary files. Default is [OUT]/tmp","GENOMESTRIP_OUT_TMP_DIR"],
    "gs-dir=s" => [\$gsdir, "GenomeSTRiP svtoolkit directory", "GENOMESTRIP_SVTOOLKIT_DIR"],
    "param=s" => [\$paramf, "GenomeSTRIP parameter file", "GENOMESTRIP_PARAM"],
    "ref=s" => [\$ref, "Reference FASTA file", "REF"],
    "mask=s" => [\$maskf, "Reference mask FASTA file", "GENOMESTRIP_MASK_FASTA"],
    "ploidy-map=s" => [\$mapf, "Ploidy map file", "GENOMESTRIP_PLOIDY_MAP"],
    "mosix-opt=s" => [\$mosixopts, "MOSIX options", "GENOMESTRIP_MOSIX_OPT"],
    "region=s" => [\$region,"Region to focus on the variants", "GENOMESTRIP_REGION"],
    "unit=i" => [\$unit, "Number of variants to be genotyped per parallel run", "GENOMESTRIP_UNIT"],
    "--Additional Inputs",
    "in-vcf=s" => [\$invcf, "Input site VCF files used for --run-genotype or --run-thirdparty. For --run-thirdparty, this argument is required. For --run-genotype, default is [OUT]/discovery/discovery.vcf","GENOMESTRIP_SITE_VCF"],
    "pass-only" => [\$pass, "Genotype only PASS-filtered variants, default is OFF", "GENOMESTRIP_PASS_ONLY"],
    "skip-rc" => [\$skiprc, "Skip precomputing read count", "GENOMESTRIP_SKIP_RC"],
    "base-prefix=s" => [\$baseprefix,"Prefix of all files","BASE_PREFIX"],
    "bam-prefix=s" => [\$bamprefix,"Prefix of BAM files","BAM_PREFIX"],
    "ref-prefix=s"=> [\$refprefix,"Prefix of Reference FASTA files","REF_PREFIX"],
    "no-phonehome", [\$noPhoneHome,"Skip phone home functionality"],
    "make-base-name=s" => [\$makebasename,"Specifies the basename for the makefile","MAKE_BASE_NAME"],
    "verbose" => [\$verbose,"Specifies that additional details are to be printed out","VERBOSE"],
    "dry-run" => [\$dryrun,"Perform a dry-run that only produces Makefile but not run it"],
    "numjobs=i" => [\$numjobs,"Number of jobs to concurrently run"],
    "autosomes" => [\$autosomes,"Perform analysis only on autosomes"],
    ) || gcpod2usage(2);

if ( ($runMetadata ? 1 : 0) + ( $runDiscovery ? 1 : 0 ) + ( $runGenotype ? 1 : 0 ) + ($runThirdparty ? 1 : 0) > 1 ) {
    print STDERR "ERROR: --run-metadata, --run-discovery, --run-genotype, --run-thirdparty options are not compatible to each other\n";
    gcpod2usage(2);
}

unless ( $runMetadata || $runDiscovery || $runGenotype || $runThirdparty ) {
    print STDERR "ERROR: One of command options among --run-metadata, --run-discovery, --run-genotype, --run-thirdparty must be specified\n";
}

my $runcluster = "\$(GOTCLOUD_ROOT)/scripts/runcluster.pl";

my $java7 = get_java7_path();

#--------------------------------------------------------------
#   Convert command line options to conf settings
#--------------------------------------------------------------
#   Set the configuration values for applicable command-line options.
#if ($listf)    { push(@confSettings, "BAM_LIST = $listf"); }
#if ($bamprefix)  { push(@confSettings, "BAM_PREFIX = $bamprefix"); }
#if ($refprefix)  { push(@confSettings, "REF_PREFIX = $refprefix"); }
#if ($baseprefix) { push(@confSettings, "BASE_PREFIX = $baseprefix"); }
#if ($makebasename)   { push(@confSettings, "MAKE_BASE_NAME = $makebasename"); }
#if ($outdir)     { push(@confSettings, "OUT_DIR = $outdir"); }
#if ($copyglf)    { push(@confSettings, "COPY_GLF = $copyglf"); }
#if ($refdir)     { push(@confSettings, "REF_DIR = $refdir"); }
#if ($chroms)     { $chroms =~ s/,/ /g; push(@confSettings, "CHRS = $chroms"); }

## METADATA directory is always needed
if ( $outMetadata ) {
    if ( $out ) {
	print STDERR "WARNING: Overriding --out-metadata from $out/metadata/ to $outMetadata\n";
    }
}
else {
    if ( $out ) {
	$outMetadata = "$out/metadata";
    }
    else {
	print STDERR "ERROR: Neither --out nor --out-metadata is specifieid\n";
	gcpod2usage(2);
    }
}

## DISCOVERY directory 
if ( $runDiscovery || ( $runGenotype && ( !$invcf ) ) ) {
    if ( $outDiscovery ) {
	if ( $out ) {
	    print STDERR "WARNING: Overriding --out-discovery from $out/discovery/ to $outDiscovery\n";
	}
    }
    else {
	if ( $out ) {
	    $outDiscovery = "$out/discovery";
	}
	else {
	    print STDERR "ERROR: Neither --out nor --out-discovery is specifieid\n";
	    gcpod2usage(2);
	}
    }
}

## GENOTYPE directory
if ( $runGenotype ) {
    if ( $outGenotype ) {
	if ( $out ) {
	    print STDERR "WARNING: Overriding --out-genotype from $out/genotype/ to $outGenotype\n";
	}
    }
    else {
	if ( $out ) {
	    $outGenotype = "$out/genotype";
	}
	else {
	    print STDERR "ERROR: Neither --out nor --out-genotype is specifieid\n";
	    gcpod2usage(2);
	}
    }
    if ( $outDiscovery ) {
	$invcf = "$outDiscovery/discovery.vcf" unless ( $invcf );
    }
    else {
	$invcf = "$out/discovery/discovery.vcf" unless ( $invcf );
    }
}

## THIRDPARTY directory
if ( $runThirdparty ) {
    if ( $outThirdparty ) {
	if ( $out ) {
	    print STDERR "WARNING: Overriding --out-thirdparty from $out/thirdparty/ to $outThirdparty\n";
	}
    }
    else {
	if ( $out ) {
	    $outThirdparty = "$out/thirdparty";
	}
	else {
	    print STDERR "ERROR: Neither --out nor --out-thirdparty is specifieid\n";
	    gcpod2usage(2);
	}
    }
    unless ( $invcf ) {
	print STDERR "ERROR: --in-vcf must be specified with --run-thirdparty option";
	gcpod2usage(2);
    }
}


my %requiredOpts = (
                    list => $listf,
                    out   => $out,
                    outdir => $outdir
                   );

foreach my $rOpt (keys %requiredOpts)
{
    unless ( $requiredOpts{$rOpt} ) {
        print STDERR "ERROR: Missing required option, $rOpt\n";
        gcpod2usage(2);
    }
}

#die "Please specify the full path for --out $out\n" unless ( $out =~ /^\// );
unless ( (!$out) || ( -d $out ) ) {
    make_path($out) || die "Cannot create $out\n";
}

unless ( (!$outMetadata) || ( -d $outMetadata ) ) {
    make_path($outMetadata) || die "Cannot create $outMetadata\n";
    mkdir("$outMetadata/cpt") || die "Cannot create $outMetadata/cpt\n";
}

unless ( (!$outDiscovery) || ( -d $outDiscovery ) ) {
    make_path($outDiscovery) || die "Cannot create $outDiscovery\n";
}

unless ( (!$outGenotype) || ( -d $outGenotype ) ) {
    make_path($outGenotype) || die "Cannot create $outGenotype\n";
}

unless ( (!$outThirdparty) || ( -d $outThirdparty ) ) {
    make_path($outThirdparty) || die "Cannot create $outThirdparty\n";
}

unless ( $out ) {
    if ( $runMetadata ) {
	$out = $outMetadata;
    }
    elsif ( $runDiscovery ) {
	$out = $outDiscovery;
    }
    elsif ( $runGenotype ) {
	$out = $outGenotype;
    }
    elsif ( $runThirdparty ) {
	$out = $outThirdparty;
    }
    else {
	print STDERR "ERROR: --out is unspecified. No command option is specified";
	gcpod2usage(2);
    }
}

unless ($tmpdir) {
    $tmpdir = "$out/.queue/tmp";
}

gcstatus();


## read parameter file
my $isradius = "10.0";
my $maxisstdev = "3";
my $minMapQ = 10;

open(IN,$paramf) || die "Cannot open $paramf file\n";
while(<IN>) {
    next if ( /^#/ );
    if ( /^([^:]+): (.*)$/ ) {
	my ($key,$val) = ($1,$2);
	## currently do nothing
    }
}
close IN;

setConf("BAM_PREFIX",$bamprefix) if ( $bamprefix );
setConf("BASE_PREFIX",$baseprefix) if ( $baseprefix );
setConf("REF_PREFIX",$refprefix) if ( $refprefix );

#die getConf("BAM_PREFIX");

my @ids = ();
my @bams = ();
my @fns = ();

unless ( $listf ) {
    print STDERR "ERROR: Empty --list (in argument) or BAM_LIST (in config file)\n";
    gcpodusage(2);
}

$gsdir = &getAbsPath($gsdir);
$listf = &getAbsPath($listf);
$ref = &getAbsPath($ref);
$maskf = &getAbsPath($maskf);
$mapf = &getAbsPath($mapf);

open(IN,$listf) || die "Cannot read $listf, check your setting of --list (in argument) or BAM_LIST (in config file)\n";
while(<IN>) {
    my ($id,$bam) = split;
    my @F = split(/\//,$bam);
    $F[$#F] =~ s/.bam$//;

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
	    $bam = &getAbsPath($bam, "BAM");
	}
    }
    if($bam =~ /.cram$/)
    {
        die "ERROR: $bam is a CRAM file, but genomestrip does not currently support CRAM.\n";
    }

    push(@ids,$id);
    push(@bams,$bam);
    push(@fns,$F[$#F]);
}
close IN;

$ref = &getAbsPath($ref);
&initRef($ref);

my ($startbp,$endbp) = (0,0);
my @chrs = ();
foreach my $c (@achrs) {
    if ( $c =~ /^(chr)?(\d+|X|Y|M|MT)$/ ) {
	next if ( ( $autosomes) && ( $c =~ /^(chr)?(X|Y|M|MT)$/ ) );
	push(@chrs,$c);
    }
}
die "ERROR: Empty chromosomes list\n" if ( $#chrs < 0 );

my %hchrs = ();
if ( $region ) {
    my ($chr2,$beg2,$end2) = split(/[:\-]+/,$region);
    die "Cannot parse $region\n" unless ( defined($chr2) );
    @chrs = ($chr2);
    $startbp = $beg2 if ( defined($beg2) );
    $endbp = $end2 if ( defined($end2) );
    die "Cannot find $chr2\n" unless ( defined($hszchrs{$chr2}) );
    $endbp = $hszchrs{$chr2}->[3] if ( $endbp == 0 );
    $hchrs{$chr2} = [$startbp,$endbp];
}
else {
    foreach my $chr (@chrs) {
	$hchrs{$chr} = [1,$hszchrs{$chr}->[3]];
    }
}
    
my $Rdir = "/net/fantasia/home/hmkang/bin/R/bin";
my $setenv = "export PATH=$Rdir:$gsdir:/usr/bin:$gsdir/bwa/:\${PATH}; export SV_DIR=$gsdir; mkdir --p $tmpdir";
my $queuecmd = "$java7 -Xmx4g -XX:+UseParallelOldGC -XX:ParallelGCThreads=4 -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Djava.io.tmpdir=$tmpdir -cp $gsdir/lib/SVToolkit.jar:$gsdir/lib/gatk/GenomeAnalysisTK.jar:$gsdir/lib/gatk/Queue.jar";

open(MAK,">$out/Makefile") || die "Cannot open file $out/Makefile\n";
print MAK ".DELETE_ON_ERROR:\n\n";
print MAK "all:".($runMetadata ? " metadata" : "").($runDiscovery ? " discovery" : "").($runGenotype ? " genotype" : "").($runThirdparty ? " thirdparty" : "")."\n\n";
print MAK "\techo 'Successfully finished GenomeSTRiP pipeline'\n\n";

if ( $runMetadata ) {
    print MAK "metadata: $outMetadata/cpt/mkdir.OK $outMetadata/cpt/gcprof.OK $outMetadata/cpt/size.OK $outMetadata/cpt/hist.OK $outMetadata/cpt/depthspan.OK".($skiprc ? "" : " $outMetadata/cpt/rccache.OK")."\n";
    print MAK "\techo 'Successfully finished GenomeSTRiP metadata pipeline'\n\n";

    print MAK "$outMetadata/cpt/mkdir.OK:\n";
    print MAK "\tmkdir --p $outMetadata/depth\n";
    print MAK "\tmkdir --p $outMetadata/spans\n";
    print MAK "\tmkdir --p $outMetadata/isd\n";
    print MAK "\tmkdir --p $outMetadata/gcprofile\n";
    if ( !$skiprc ) {
	print MAK "\tmkdir --p $outMetadata/rccache\n";
	print MAK "\tmkdir --p $outMetadata/rccache.merge\n";
    }
    print MAK "\ttouch $outMetadata/cpt/mkdir.OK\n\n";

    print MAK "$outMetadata/cpt/size.OK: $outMetadata/cpt/mkdir.OK\n";
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.ComputeGenomeSizes ".($mapf ? " -ploidyMapFile $mapf" : "")." -O $outMetadata/genome_sizes.txt -R $ref -genomeMaskFile $maskf",$mosixopts);
    print MAK "\tls $outMetadata/genome_sizes.txt\n";
    print MAK "\ttouch $outMetadata/cpt/size.OK\n\n";
    
    print MAK "$outMetadata/cpt/gcprof.OK: $outMetadata/cpt/mkdir.OK $outMetadata/cpt/gcprof.reference.OK ".&joinps(" ","$outMetadata/cpt/",".gcprof.OK",@fns)."\n\n";

    ## write a list file
    open(OUT,">$outMetadata/gcprofiles.list");
    for(my $i=0; $i < @fns; ++$i) {
	print OUT "$outMetadata/gcprofile/$fns[$i].gcprof.zip\n";
    }
    close OUT;

    #print MAK &mosixCmd("$setenv; ".&xargsCmd("$outMetadata/cpt/gcprof.cmd","$queuecmd org.broadinstitute.sv.apps.MergeGCProfiles ".&joinps(" ","-I $outMetadata/gcprofile/",".gcprof.zip",@fns)." -O $outMetadata/gcprofiles.zip"),$mosixopts)."\n\n";
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.MergeGCProfiles -I $outMetadata/gcprofiles.list -O $outMetadata/gcprofiles.zip",$mosixopts);
    print MAK "\tls $outMetadata/gcprofiles.zip\n";	
    print MAK "\ttouch $outMetadata/cpt/gcprof.OK\n\n";

    print MAK "$outMetadata/cpt/gcprof.reference.OK: $outMetadata/cpt/mkdir.OK\n\n";
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.ComputeGCProfiles -O $outMetadata/gcprofile/reference.gcprof.zip -R $ref -md $outMetadata -writeReferenceProfile true -genomeMaskFile $maskf -configFile $paramf",$mosixopts);
    print MAK "\tls $outMetadata/gcprofile/reference.gcprof.zip\n";
    print MAK "\ttouch $outMetadata/cpt/gcprof.reference.OK\n\n";

    for(my $i=0; $i < @fns; ++$i) {
	print MAK "$outMetadata/cpt/$fns[$i].gcprof.OK: $outMetadata/cpt/gcprof.reference.OK\n";
	print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.main.SVCommandLine -T ComputeGCProfileWalker -R $ref -I $bams[$i] -O $outMetadata/gcprofile/$fns[$i].gcprof.zip -disableGATKTraversal true -md $outMetadata -referenceProfile $outMetadata/gcprofile/reference.gcprof.zip -genomeMaskFile $maskf -insertSizeRadius $isradius",$mosixopts);
	print MAK "\tls $outMetadata/gcprofile/$fns[$i].gcprof.zip\n";
	print MAK "\ttouch $outMetadata/cpt/$fns[$i].gcprof.OK\n";
    }
    
    ## write a list file
    open(OUT,">$outMetadata/isd.dist.args.list");
    for(my $i=0; $i < @fns; ++$i) {
	print OUT "-I $outMetadata/isd/$fns[$i].dist.bin\n";
    }
    print OUT "-O $outMetadata/isd.dist.bin\n";
    close OUT;

    print MAK "$outMetadata/cpt/hist.OK: $outMetadata/cpt/mkdir.OK ".&joinps(" ","$outMetadata/cpt/hist.",".OK",@fns)."\n";
    #print MAK &mosixCmd("$setenv; ".&xargsCmd("$outMetadata/cpt/hist.cmd","$queuecmd org.broadinstitute.sv.apps.MergeInsertSizeDistributions ".&joinps(" ","-I $outMetadata/isd/",".dist.bin",@fns)." -O $outMetadata/isd.dist.bin"),$mosixopts);
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.MergeInsertSizeDistributions -args $outMetadata/isd.dist.args.list",$mosixopts);
    print MAK "\tls $outMetadata/isd.dist.bin\n";
    print MAK "\ttouch $outMetadata/cpt/hist.OK\n\n";
    for(my $i=0; $i < @fns; ++$i) {
	print MAK "$outMetadata/cpt/hist.$fns[$i].OK: $outMetadata/cpt/mkdir.OK\n";
	print MAK "\tsleep ".sprintf("%.2lf",rand(30))."\n";
	print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.main.SVCommandLine -T ComputeInsertSizeHistogramsWalker -R $ref -I $bams[$i] -O $outMetadata/isd/$fns[$i].hist.bin -disableGATKTraversal true -md $outMetadata",$mosixopts);
	print MAK "\tls $outMetadata/isd/$fns[$i].hist.bin\n";
	print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.ReduceInsertSizeHistograms -I $outMetadata/isd/$fns[$i].hist.bin -O $outMetadata/isd/$fns[$i].dist.bin",$mosixopts);
	print MAK "\tls $outMetadata/isd/$fns[$i].dist.bin\n";	
	print MAK "\ttouch $outMetadata/cpt/hist.$fns[$i].OK\n\n";
    }

    ## write a list file
    open(OUT,">$outMetadata/depth.args.list");
    for(my $i=0; $i < @fns; ++$i) {
	print OUT "-I $outMetadata/depth/$fns[$i].depth.txt\n";
    }
    print OUT "-O $outMetadata/depth.dat\n";
    close OUT;

    ## write a list file
    open(OUT,">$outMetadata/spans.args.list");
    for(my $i=0; $i < @fns; ++$i) {
	print OUT "-I $outMetadata/spans/$fns[$i].spans.txt\n";
    }
    print OUT "-O $outMetadata/spans.dat\n";
    close OUT;
    
    print MAK "$outMetadata/cpt/depthspan.OK: $outMetadata/cpt/mkdir.OK ".&joinps(" ","$outMetadata/cpt/depthspan.",".OK",@fns)."\n";
    #print MAK &mosixCmd("$setenv; ".&xargsCmd("$outMetadata/cpt/depth.cmd","$queuecmd org.broadinstitute.sv.apps.MergeReadDepthCoverage ".&joinps(" ","-I $outMetadata/depth/",".depth.txt",@fns)." -O $outMetadata/depth.dat"),$mosixopts);
    #print MAK &mosixCmd("$setenv; ".&xargsCmd("$outMetadata/cpt/spans.cmd","$queuecmd org.broadinstitute.sv.apps.MergeReadSpanCoverage ".&joinps(" ","-I $outMetadata/spans/",".spans.txt",@fns)." -O $outMetadata/spans.dat"),$mosixopts);
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.MergeReadDepthCoverage -args $outMetadata/depth.args.list",$mosixopts);
    print MAK "\tls $outMetadata/depth.dat\n";
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.MergeReadSpanCoverage -args $outMetadata/spans.args.list",$mosixopts);
    print MAK "\tls $outMetadata/spans.dat\n";    
    print MAK "\ttouch $outMetadata/cpt/depthspan.OK\n\n";
    for(my $i=0; $i < @fns; ++$i) {
	print MAK "$outMetadata/cpt/depthspan.$fns[$i].OK: $outMetadata/cpt/mkdir.OK $outMetadata/cpt/hist.OK\n";
	print MAK "\tsleep ".sprintf("%.2lf",rand(30))."\n";
	print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.main.SVCommandLine -T ComputeMetadataWalker -R $ref -I $bams[$i] -disableGATKTraversal true -md $outMetadata -depthFile $outMetadata/depth/$fns[$i].depth.txt -spanFile $outMetadata/spans/$fns[$i].spans.txt -genomeMaskFile $maskf -minMapQ $minMapQ -insertSizeRadius $isradius",$mosixopts);
	print MAK "\tls $outMetadata/depth/$fns[$i].depth.txt\n";
	print MAK "\tls $outMetadata/spans/$fns[$i].spans.txt\n";		
	print MAK "\ttouch $outMetadata/cpt/depthspan.$fns[$i].OK\n\n";
    }

    if ( !$skiprc ) {
	## write a list file
	open(OUT,">$outMetadata/computerc.args.list");
	for(my $i=0; $i < @fns; ++$i) {
	    print OUT "-I $outMetadata/rccache/$fns[$i].rc.bin\n";
	}
	print OUT "-O $outMetadata/rccache.list\n";
	close OUT;
	
	print MAK "$outMetadata/cpt/rccache.OK: $outMetadata/cpt/computerc.OK $outMetadata/cpt/mergerc.OK\n\n";
	print MAK "$outMetadata/cpt/computerc.OK: $outMetadata/cpt/mkdir.OK ".&joinps(" ","$outMetadata/cpt/computerc.",".OK",@fns)."\n";
	print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.queue.WriteFileList -args $outMetadata/computerc.args.list",$mosixopts);
	print MAK "\tls $outMetadata/rccache.list\n";		
	print MAK "\ttouch $outMetadata/cpt/computerc.OK\n\n";
	for(my $i=0; $i < @fns; ++$i) {
	    print MAK "$outMetadata/cpt/computerc.$fns[$i].OK: $outMetadata/cpt/mkdir.OK\n";
	    print MAK "\tsleep ".sprintf("%.2lf",rand(30))."\n";
	    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.main.SVCommandLine -T ComputeReadCountsWalker -R $ref -I $bams[$i] -O $outMetadata/rccache/$fns[$i].rc.bin -disableGATKTraversal true -md $outMetadata -genomeMaskFile $maskf -minMapQ $minMapQ -insertSizeRadius $isradius",$mosixopts);
	    print MAK "\tls $outMetadata/rccache/$fns[$i].rc.bin\n";	    
	    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.IndexReadCountFile -I $outMetadata/rccache/$fns[$i].rc.bin -O $outMetadata/rccache/$fns[$i].rc.bin.idx",$mosixopts);
	    print MAK "\tls $outMetadata/rccache/$fns[$i].rc.bin.idx\n";
	    print MAK "\ttouch $outMetadata/cpt/computerc.$fns[$i].OK\n\n";
	}
	
	my @bins = ();
	my @mcmds = ();
	my @icmds = ();
	
	my $seq = 1;
	foreach my $chr (@chrs) {
	    for(my $i=0; $i < $hszchrs{$chr}->[3]; $i += $rcWindowSize ) {
		my $beg = $i+1;
		my $end = $i + $rcWindowSize;
		$end = $hszchrs{$chr}->[3] if ( $end > $hszchrs{$chr}->[3] );
		
		if ( $beg > 0 ) {
		    if ( $startbp > $end ) {
			next;
		    }
		    elsif ( $startbp > $beg ) {
			$beg = $startbp;
		    }
		}
		
		if ( $endbp > 0 ) {
		    if ( $endbp < $beg ) {
			next;
		    }
		    elsif ( $endbp < $end ) {
			$end = $endbp;
		    }
		}
		my $prefix = sprintf("P%04d",$seq);
		
		my $locus = "$chr:$beg-$end";
		my $bin = "$outMetadata/rccache.merge/$prefix.rccache.bin";
		push(@bins,$bin);
		push(@mcmds,"$setenv; $queuecmd org.broadinstitute.sv.apps.MergeReadCounts -I $outMetadata/rccache.list -O $bin -R $ref -L $locus");
		push(@icmds,"$setenv; $queuecmd org.broadinstitute.sv.apps.IndexReadCountFile -I $bin -O $bin.idx");
		++$seq;
	    }
	}

	print MAK "$outMetadata/cpt/mergerc.OK: $outMetadata/cpt/computerc.OK $outMetadata/cpt/mkdir.OK ".&joinps(" ","",".OK",@bins)."\n";
	print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.MergeReadCounts ".&joinps(" "," -I ","",@bins)." -O $outMetadata/rccache.bin -R $ref",$mosixopts);
	print MAK "\tls $outMetadata/rccache.bin\n";
	print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.IndexReadCountFile -I $outMetadata/rccache.bin -O $outMetadata/rccache.bin.idx",$mosixopts);
	print MAK "\ttouch $outMetadata/cpt/mergerc.OK\n\n";
	print MAK "\tls $outMetadata/rccache.bin.idx\n";
	
	for(my $i=0; $i < @bins; ++$i) {
	    print MAK "$bins[$i].OK: $outMetadata/cpt/computerc.OK $outMetadata/cpt/mkdir.OK\n";
	    print MAK &mosixCmd($mcmds[$i],$mosixopts);
	    print MAK "\tls $bins[$i]\n";
	    print MAK &mosixCmd($icmds[$i],$mosixopts);
	    print MAK "\tls $bins[$i].idx\n";	    
	    print MAK "\ttouch $bins[$i].OK\n\n";
	}
    }
}

if ( $runDiscovery ) {
    unless ( ( -s "$outMetadata/gcprofiles.zip" ) && ( -s "$outMetadata/genome_sizes.txt" ) && ( -s "$outMetadata/isd.dist.bin" ) && ( -s "$outMetadata/depth.dat" ) && ( -s "$outMetadata/spans.dat" ) ) {
	die "Metadata $outMetadata is not completely generated. Please finish metadata step first\n";
    }

    my $outvcf = "$outDiscovery/discovery.vcf";
    
    my @prefixes = ();
    my @loci = ();
    my @window = ();
    my @vcfs = ();
    my @cmds = ();
    my $seq = 1;

    open(OUT,">$outDiscovery/discovery.bams.args.list");
    foreach my $bam (@bams) {
	print OUT "$bam\n";
    }
    close OUT;

    foreach my $chr (@chrs) {
	for(my $i=0; $i < $hszchrs{$chr}->[3]; $i += $windowSize ) {
	    my $beg = $i+1;
	    my $end = $i + $windowSize;
	    $end = $hszchrs{$chr}->[3] if ( $end > $hszchrs{$chr}->[3] );
	    
	    if ( $beg > 0 ) {
		if ( $startbp > $end ) {
		    next;
		}
		elsif ( $startbp > $beg ) {
		    $beg = $startbp;
		}
	    }
	    
	    if ( $endbp > 0 ) {
		if ( $endbp < $beg ) {
		    next;
		}
		elsif ( $endbp < $end ) {
		    $end = $endbp;
		}
	    }
	    
	    my $locus = "$chr:$beg-$end";
	    push(@loci,$locus);
	    my $wbeg = ( $beg < $windowPadding ) ? 1 : ( $beg-$windowPadding );
	    my $wend = ( $end + $windowSize + $windowPadding + 1 > $hszchrs{$chr}->[3] ) ? $hszchrs{$chr}->[3] : ( $end + $windowSize + $windowPadding + 1 );
	    my $win = "$chr:$wbeg-$wend";
	    push(@window,$win);
	    my $prefix = sprintf("P%04d",$seq);
	    push(@prefixes,$prefix);
	    my $ovcf = "$outDiscovery/$prefix.discovery.vcf";
	    push(@vcfs,$ovcf);

	    #push(@cmds,"$setenv; ".&xargsCmd("$ovcf.cmd","$queuecmd org.broadinstitute.sv.main.SVDiscovery -T SVDiscoveryWalker -R $ref ".&joinps(" ","-I ","",@bams)." -O $ovcf -md $outMetadata -disableGATKTraversal true -configFile $paramf -runDirectory $outDiscovery -genomeMaskFile $maskf -partitionName $prefix -runFilePrefix $prefix -L $win -searchLocus $locus -searchWindow $win -searchMinimumSize $minimumSize -searchMaximumSize $maximumSize"));
	    push(@cmds,"$setenv; $queuecmd org.broadinstitute.sv.main.SVDiscovery -T SVDiscoveryWalker -R $ref -I $outDiscovery/discovery.bams.args.list -O $ovcf -md $outMetadata -disableGATKTraversal true -configFile $paramf -runDirectory $outDiscovery -genomeMaskFile $maskf -partitionName $prefix -runFilePrefix $prefix -L $win -searchLocus $locus -searchWindow $win -searchMinimumSize $minimumSize -searchMaximumSize $maximumSize; ls $ovcf");
	    ++$seq;
	}
    }
    print MAK "discovery: $outvcf.OK\n";
    print MAK "\techo 'Successfully finished GenomeSTRiP discovery pipeline'\n\n";
    print MAK "$outvcf.OK: ".&joinps(" ","",".OK",@vcfs)."\n";
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.apps.MergeDiscoveryOutput -O $outDiscovery/discovery.unfiltered.vcf -runDirectory $outDiscovery");
    print MAK "\tls $outDiscovery/discovery.unfiltered.vcf\n";
    print MAK &mosixCmd("$setenv; $queuecmd -jar $gsdir/lib/gatk/GenomeAnalysisTK.jar -T VariantFiltration -V $outDiscovery/discovery.unfiltered.vcf -o $outvcf -R $ref -no_cmdline_in_header -filterName COVERAGE -filter \"GSDEPTHCALLTHRESHOLD == \\\"NA\\\" || GSDEPTHCALLTHRESHOLD >= 1.0\" -filterName COHERENCE -filter \"GSCOHPVALUE == \\\"NA\\\" || GSCOHPVALUE <= 0.01\" -filterName DEPTHPVAL -filter \"GSDEPTHPVALUE == \\\"NA\\\" || GSDEPTHPVALUE >= 0.01\" -filterName DEPTH -filter \"GSDEPTHRATIO == \\\"NA\\\" || GSDEPTHRATIO > 0.8 || (GSDEPTHRATIO > 0.63 && (GSMEMBPVALUE == \\\"NA\\\" || GSMEMBPVALUE >= 0.01))\" -filterName PAIRSPERSAMPLE -filter \"GSNPAIRS <= 1.1 * GSNSAMPLES\"");
    print MAK "\tls $outvcf\n";    
    print MAK "\ttouch $outvcf.OK\n\n";
    for(my $i=0; $i < @vcfs; ++$i) {
	print MAK "$vcfs[$i].OK:\n";
	print MAK "\tsleep ".sprintf("%.2lf",rand(30))."\n";    
	print MAK &mosixCmd($cmds[$i],$mosixopts);
	print MAK "\ttouch $vcfs[$i].OK\n\n";
    }
}

if ( $runGenotype ) {
    unless ( ( -s "$outMetadata/gcprofiles.zip" ) && ( -s "$outMetadata/genome_sizes.txt" ) && ( -s "$outMetadata/isd.dist.bin" ) && ( -s "$outMetadata/depth.dat" ) && ( -s "$outMetadata/spans.dat" ) ) {
	die "Metadata $outMetadata is not completely generated. Please finish metadata step first\n";
    }

    open(OUT,">$outGenotype/genotype.bams.args.list");
    foreach my $bam (@bams) {
	print OUT "$bam\n";
    }
    close OUT;

    my $outvcf = "$outGenotype/genotype.vcf";
    my $outpref = "$outGenotype/genotype";

    print STDERR "Reading $invcf...\n";
## parse the input VCF file
    my @headers = ();
    my @lines = ();
    open(VCF,$invcf) || die "Cannot open $invcf\n";
    while(<VCF>) {
	if ( /^#/ ) {
	    push(@headers,$_);
	}
	else {
	    my @F = split;
	    next if ( ( $F[6] ne "PASS" ) && ( $pass ) );
	    if ( defined($hchrs{$F[0]}) ) {
		if ( ( $F[1] >= $hchrs{$F[0]}->[0] ) && ( $F[1] <= $hchrs{$F[0]}->[1] ) ) {
		    push(@lines,$_);
		}
	    }
	}
    }
    close VCF;
    
    print STDERR "Splitting input VCF into pieces of $unit variants\n";
    my @svcfs = ();
    for(my $i=0; $i <= $#lines; $i += $unit) {
	my $svcf = sprintf("$outGenotype/sites.P%04d.vcf",$i/$unit+1);
	open(OUT,">$svcf") || die "Cannot open file\n";
	foreach my $header (@headers) {
	    print OUT $header;
	}
	for(my $j=$i; ($j < $i+$unit) && ( $j <= $#lines ); ++$j) {
	    print OUT $lines[$j];
	}
	push(@svcfs,$svcf);
	close OUT;
    }
    
    #my $queuecmd = "java -Xmx4096m -XX:+UseParallelOldGC -XX:ParallelGCThreads=4 -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Djava.io.tmpdir=$tmpdir -cp $gsdir/lib/SVToolkit.jar:$gsdir/lib/gatk/GenomeAnalysisTK.jar:$gsdir/lib/gatk/Queue.jar";
    my $npart = $#svcfs+1;
    
    my @ovcfs = ();
    my @cmds = ();
    for(my $i=0; $i < $npart; ++$i) {
	my $ovcf = sprintf("$outGenotype/genotypes.P%04d.vcf",$i+1);
	push(@ovcfs,$ovcf);
	#push(@cmds,"$setenv; ".&xargsCmd("$ovcf.cmd","$queuecmd org.broadinstitute.sv.main.SVGenotyper -T SVGenotyperWalker -R $ref ".&joinps(" ","-I ","",@bams)." -O $ovcf -md $outMetadata -disableGATKTraversal true -configFile $paramf -runDirectory $outGenotype -genomeMaskFile $maskf -vcf $svcfs[$i]"));
	push(@cmds,"$setenv; $queuecmd org.broadinstitute.sv.main.SVGenotyper -T SVGenotyperWalker -R $ref -I $outGenotype/genotype.bams.args.list -O $ovcf -md $outMetadata -disableGATKTraversal true -configFile $paramf -runDirectory $outGenotype -genomeMaskFile $maskf -vcf $svcfs[$i]; ls $ovcf");
    }
    print MAK "genotype: $outvcf.OK\n";
    print MAK "\techo 'Successfully finished GenomeSTRiP genotyping pipeline'\n\n";
    print MAK "$outvcf.OK: ".&joinps(" ","",".OK",@ovcfs)."\n";
    print MAK &mosixCmd("(cat $ovcfs[0] ".($#ovcfs >= 1 ? "; cat ".join(" ",@ovcfs[1..$#ovcfs])." | grep -v ^#;" : "")." ) > $outvcf");
    print MAK "\tmkdir --p $outGenotype/eval\n";
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.main.SVAnnotator -vcf $outvcf -R $ref -md $outMetadata -auxFilePrefix $outpref -reportDirectory $outGenotype -A AlleleFrequency -A SiteFilters -A VariantsPerSample -reportFileMap SiteFilters:$outGenotype/eval/GenotypeSiteFilters.report.dat -summaryFileMap SiteFilters:$outGenotype/eval/GenotypeSiteFilters.summary.dat  -writeReport true -writeSummary true");
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.main.SVAnnotator -vcf $outvcf -R $ref -md $outMetadata -auxFilePrefix $outpref -reportDirectory $outGenotype -A CopyNumberClass -writeReport true -writeSummary true");
    print MAK "\tcat $outvcf | $gcroot/bin/bgzip -c > $outvcf.gz\n";
    print MAK "\t$gcroot/bin/tabix -pvcf $outvcf.gz\n";
    print MAK "\ttouch $outvcf.OK\n\n";
    for(my $i=0; $i < @ovcfs; ++$i) {
	print MAK "$ovcfs[$i].OK:\n";
	print MAK &mosixCmd($cmds[$i],$mosixopts);
	print MAK "\ttouch $ovcfs[$i].OK\n\n";
    }
}

if ( $runThirdparty ) {
    unless ( ( -s "$outMetadata/gcprofiles.zip" ) && ( -s "$outMetadata/genome_sizes.txt" ) && ( -s "$outMetadata/isd.dist.bin" ) && ( -s "$outMetadata/depth.dat" ) && ( -s "$outMetadata/spans.dat" ) ) {
	die "Metadata $outMetadata is not completely generated. Please finish metadata step first\n";
    }

    my $outvcf = "$outThirdparty/genotype.vcf";
    my $outpref = "$outThirdparty/genotype";

    open(OUT,">$outThirdparty/thirdparty.bams.args.list");
    foreach my $bam (@bams) {
	print OUT "$bam\n";
    }
    close OUT;

    print STDERR "Reading $invcf...\n";
## parse the input VCF file
    my @headers = ();
    my @lines = ();
    open(VCF,$invcf) || die "Cannot open $invcf\n";
    while(<VCF>) {
	if ( /^#/ ) {
	    push(@headers,$_);
	}
	else {
	    my @F = split;
	    next if ( ( $F[6] ne "PASS" ) && ( $pass ) );
	    if ( defined($hchrs{$F[0]}) ) {
		if ( ( $F[1] >= $hchrs{$F[0]}->[0] ) && ( $F[1] <= $hchrs{$F[0]}->[1] ) ) {
		    push(@lines,$_);
		}
	    }
	}
    }
    close VCF;
    
    print STDERR "Splitting input VCF into pieces of $unit variants\n";
    my @svcfs = ();
    for(my $i=0; $i <= $#lines; $i += $unit) {
	my $svcf = sprintf("$outThirdparty/sites.P%04d.vcf",$i/$unit+1);
	open(OUT,">$svcf") || die "Cannot open file\n";
	foreach my $header (@headers) {
	    print OUT $header;
	}
	for(my $j=$i; ($j < $i+$unit) && ( $j <= $#lines ); ++$j) {
	    print OUT $lines[$j];
	}
	push(@svcfs,$svcf);
	close OUT;
    }
    
    #my $setenv = "export PATH=$gsdir:/usr/bin:$gsdir/bwa/:\${PATH}; export SV_DIR=$gsdir; mkdir --p $tmpdir";
    #my $queuecmd = "java -Xmx4096m -XX:+UseParallelOldGC -XX:ParallelGCThreads=4 -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Djava.io.tmpdir=$tmpdir -cp $gsdir/lib/SVToolkit.jar:$gsdir/lib/gatk/GenomeAnalysisTK.jar:$gsdir/lib/gatk/Queue.jar";
    my $npart = $#svcfs+1;
    
    my @ovcfs = ();
    my @cmds = ();
    for(my $i=0; $i < $npart; ++$i) {
	my $pref = sprintf("$outThirdparty/genotypes.P%04d",$i+1);
	my $ovcf = "$pref.vcf";
	push(@ovcfs,$ovcf);
	push(@cmds,["$setenv; $queuecmd org.broadinstitute.sv.main.SVGenotyper -T SVGenotyperWalker -R $ref -I $outThirdparty/thirdparty.bams.args.list -O $pref.unfiltered.vcf -md $outMetadata -disableGATKTraversal true -configFile $paramf -runDirectory $outThirdparty -genomeMaskFile $maskf -vcf $svcfs[$i];ls $pref.unfiltered.vcf",
		    "$setenv; $queuecmd org.broadinstitute.sv.main.SVAnnotator -O $pref.annotated.vcf -vcf $pref.unfiltered.vcf -R $ref -md $outMetadata -auxFilePrefix $pref.unfiltered.genotypes -A ClusterSeparation -A GCContent -A GenotypeLikelihoodStats -A NonVariant -A Redundancy -filterVariants false -writeReport true -writeSummary true -reportDirectory $outThirdparty -comparisonFile $pref.unfiltered.vcf -duplicateOverlapThreshold 0.5 -duplicateScoreThreshold 0.0",
		    "$setenv; $queuecmd -jar $gsdir/lib/gatk/GenomeAnalysisTK.jar -T VariantFiltration -V $pref.annotated.vcf -o $pref.vcf -R $ref  -filterName ALIGNLENGTH -filter \"GSELENGTH < 200\" -filterName CLUSTERSEP -filter \"GSCLUSTERSEP == \\\"NA\\\" || GSCLUSTERSEP <= 2.0\" -filterName GTDEPTH -filter \"GSM1 == \\\"NA\\\" || GSM1 <= 0.5 || GSM1 >= 2.0\" -filterName NONVARIANT -filter \"GSNONVARSCORE != \\\"NA\\\" && GSNONVARSCORE >= 13.0\" -filterName DUPLICATE -filter \"GSDUPLICATESCORE != \\\"NA\\\" && GSDUPLICATEOVERLAP >= 0.5 && GSDUPLICATESCORE >= 0.0\" -filterName INBREEDINGCOEFF -filter \"GLINBREEDINGCOEFF != \\\"NA\\\" && GLINBREEDINGCOEFF < -0.15\""]);
    }
    print MAK "thirdparty: $outvcf.OK\n\n";
    print MAK "\techo 'Successfully finished GenomeSTRiP thirdparty pipeline'\n\n";
    print MAK "$outvcf.OK: ".&joinps(" ","",".OK",@ovcfs)."\n";
    print MAK &mosixCmd("(cat $ovcfs[0] ".($#ovcfs >= 1 ? "; cat ".join(" ",@ovcfs[1..$#ovcfs])." | grep -v ^#;" : "")." ) > $outvcf");
    print MAK "\tmkdir --p $outThirdparty/eval\n";
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.main.SVAnnotator -vcf $outvcf -R $ref -md $outMetadata -auxFilePrefix $outpref -reportDirectory $outThirdparty -A AlleleFrequency -A SiteFilters -A VariantsPerSample -reportFileMap SiteFilters:$outThirdparty/eval/GenotypeSiteFilters.report.dat -summaryFileMap SiteFilters:$outThirdparty/eval/GenotypeSiteFilters.summary.dat  -writeReport true -writeSummary true");
    print MAK &mosixCmd("$setenv; $queuecmd org.broadinstitute.sv.main.SVAnnotator -vcf $outvcf -R $ref -md $outMetadata -auxFilePrefix $outpref -reportDirectory $outThirdparty -A CopyNumberClass -writeReport true -writeSummary true");
    print MAK "\tcat $outvcf | $gcroot/bin/bgzip -c > $outvcf.gz\n";
    print MAK "\t$gcroot/bin/tabix -pvcf $outvcf.gz\n";
    print MAK "\ttouch $outvcf.OK\n\n";
    for(my $i=0; $i < @ovcfs; ++$i) {
	print MAK "$ovcfs[$i].OK:\n";
	for(my $j=0; $j < 3; ++$j) {
	    print MAK &mosixCmd($cmds[$i]->[$j],$mosixopts);
	}
	print MAK "\ttouch $ovcfs[$i].OK\n\n";
    }
}

close MAK;

print "Finished writing $out/Makefile\n";
if ( $dryrun ) {
    print "Finished dry-run of GenomeSTRiP pipeline\n";
    print "Run 'make -f $out/Makefile -n | less' for sanity checking\n";
}
else {
    &forkExecWait("make -f $out/Makefile -j $numjobs");
}



sub binary_is_java7 {
    my $java_path = shift;
    if ($java_path =~ m{^\s+|\s+\z}) {die "java_path [$java_path] has leading or trailing whitespace."}
    my $java_version_output = `$java_path -version 2>&1`;
    if ($? != 0) { return 0; }
    if (not $java_version_output =~ m{^java version "(.*?)"}) {die "Couldn't find a java version in [$java_version_output]."}
    my $java_version = $1;
    return ($java_version =~ m{1\.7\.});
}

sub get_java7_path {
    my @java_paths = (getConf("JAVA7"), `which java`);
    foreach my $java_path (@java_paths) {
        $java_path =~ s{^\s+|\s+\z}{}g; # strip whitespace
        if ($java_path ne '' and -x $java_path) {
            if (binary_is_java7 $java_path) {
                return $java_path;
            }
        }
    }
    die 'Could not find Java7.  Add something like `JAVA7=/usr/lib/jvm/jdk1.7.0_25/bin/java` to your conf.';
}
