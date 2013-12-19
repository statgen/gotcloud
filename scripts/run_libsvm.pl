#!/usr/bin/perl -w

use strict;
use English;
use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin";

my $cmd = "";
my $cmdPath = $0;
my $invcf = "";
my $out = "";
my $cmdDir = $cmdPath; $cmdDir =~ s/\/[^\/]+$//; $cmdDir =~ s/\/[^\/]+$//;
#my $bin = "$cmdDir/invNorm/bin/invNorm";
my $bin = "/net/fantasia/home/hmkang/code/working/umake/invNorm/bin/invNorm";
my @ignores = qw(AC AF HWDAF);
my @bfiles = ();
my @nfiles = ();
my $svmlearn = "/net/fantasia/home/gjun/bin/svm-train";
my $svmclassify = "/net/fantasia/home/gjun/bin/svm-predict";
my $subsample = 100;
my $possample = 100;
my $negsample = 100;
my @includes = ();
my $checkNA = 1;
my $keepData = "";
my $numFilter = 3;
my $model = "";
my $ignoreALL = "";
my $cutoff = 0;
my $keyword = "SVM";
my $result = GetOptions("invcf=s",\$invcf,
		"out=s",\$out,
		"bin=s",\$bin,
		"bfile=s",\@bfiles,
		"nfile=s",\@nfiles,
		"svmlearn=s",\$svmlearn,
		"svmclassify=s",\$svmclassify,
		"ignore=s",\@ignores,
		"include=s",\@includes,
		"subsample=i",\$subsample,
		"pos=i",\$possample,
		"neg=i",\$negsample,
		"numFilter=i",\$numFilter,
		"checkNA",\$checkNA,
		"keepData",\$keepData,
		"keyword=s",\$keyword,
		"model=s",\$model,
		"threshold=i",\$cutoff,
		"ignoreALL",\$ignoreALL,
		);

#my $usage = "Usage: perl run_svm.pl --invcf [$invcf] --out [$out] --ignore [@ignores] --include [@includes] --checkNA\n";

my $usage = <<END;
--------------------------------------------------------------------------------
run_svm.pl : run SVM filtering on VCF using INFO field
--------------------------------------------------------------------------------
This program takes a VCF as an input and produces an output VCF with additional
INFO field entries. For each INFO field entry (+ QUAL field) with [NAME], the 
program appends a corresponding INFO field inverse-normal transformed as INFO
field key "IN_[NAME]". A C++ binary 'invNorm' is required for execution
--------------------------------------------------------------------------------
Usage: perl run_svm.pl --invcf [input VCF file] --out [output VCF] \
	--ignore [INFO-field-to-ignore] --bin [invNorm binary path]\
	--include [INFO-field,default-value to include] --checkNA
	Options:
	--invcf : Input VCF file with rich set of INFO fields to be inverse normalized
	--out : Output VCF file with SVM score appended to INFO fields 
	--checkNA : Check if the value is numeric and convert them into default value
	(0, or value given by --include) if the value is non-numeric
	--keepData : keep intermediate files
	--numFilter : number of filters to be used for negative examples (default: 3)
	--bin : filepath of invNorm C++ binary. (default: ../invNorm/bin/invNorm)
	--bfile : list of VCF.gz files that contains positive example sites
	--nfile : list of VCF.gz files that contains negative example sites (set --numFilter 0 to use nfile only)
	--svmlearn : file path of svm_learn binary
	--svmclassify : file path of svm_classify binary
	--subsample : subsample rate (%),  default is 100
	--pos : subsample rate (%) for positive class,  default is 100
	--neg : subsample rate (%) for negative class,  default is 100
	--ignore : INFO field entries to ignore (default: AC, AF)
	--keyword : Keyword to be used with filter score in the final VCF
	--include : INFO field (possible with [,default-value]) to always include
		This option is helpful when certain INFO field entries occasionally
		exists onlu in some variant. Default value (zero or given followed by 
		comma) will be added for the variant without the field
--------------------------------------------------------------------------------
END

unless ( ( $result ) && ( ( $invcf ) || ( $out ) ) ) {
	die "Error in parsing options\n$usage\n";
}

if (@bfiles == 0)
{
	push(@bfiles, "/net/fantasia/home/hmkang/data/GATK-resources/1000G_omni2.5.b37.sites.PASS.vcf.gz");
	push(@bfiles, "/net/fantasia/home/hmkang/data/GATK-resources/hapmap_3.3.b37.sites.PASS.vcf.gz");
}

if ($possample == 100 && $negsample == 100 && $subsample < 100)
{
	$possample = $subsample;
	$negsample = $subsample;
}

if ($ignoreALL)
{
	push(@includes, "QUAL");
}

my @names = ();

my %hIgnores = map { $_ => 1 } @ignores;
my %hIncludes = ();
my @includeKeys = ();
my @includeDefaultValues = ();
for(my $i=0; $i < @includes; ++$i) {
	my ( $key, $defaultVal ) = split(/,/,$includes[$i]);
	$hIncludes{$key} = $i;
	push(@names,$key);
	push(@includeKeys,$key);
	push(@includeDefaultValues,defined($defaultVal) ? $defaultVal : 0);
}
my $nIncludes = $#includes + 1;

open(OUT,">$out.raw") || die "Cannot open file\n";

my $in = openInFile($invcf);
my $ncols = 0;
while(<$in>) {
	next if ( /^#/ );
	my ($chrom,$pos,$id,$ref,$alt,$qual,$filt,$info) = split(/[\t\r\n]+/);
	$info .= ";QUAL=$qual" unless ( $qual eq "." );
	my @infos = split(/;/,$info);
	my @values = ();
	my $j = 0;
	for(my $i=0; $i < @includeKeys; ++$i) {
		push(@values,$includeDefaultValues[$i]);
		++$j;
	}

	for(my $i=0; $i < @infos; ++$i) {
		my ($key,$val) = split(/=/,$infos[$i]);
		next if ( defined($hIgnores{$key})  || ($ignoreALL && !defined($hIncludes{$key}))); ## skip if ignored, or not in includes key
			next unless defined($val); ## skip keys without any values

# check if exist in the includes flag
			if ( defined($hIncludes{$key}) ) {
				if ( !($checkNA) || ($val =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/ ) ) {
					$values[$hIncludes{$key}] = $val; # set value if given
				}
			}
			else {
				if ($ignoreALL)
				{
					die "Error. --ignoreALL is set but $key is not in include list";
				}
				if ( !($checkNA) || ( $val =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/ ) ) {
					push(@values,$val);
				}
				else {
					push(@values,0);
				}

				if ( $ncols == 0 ) {
					push(@names,$key);
				}
				else {
					die "Cannot recognize $key in $infos[$i], supposed to be $names[$j] at $j, $chrom:$pos:$ref:$alt $info\n" unless ($names[$j] eq $key );
				}
				++$j;
			}
	}
	if ( $ncols == 0 ) {
		$ncols = $#names+1;
	}
	elsif ( $ncols != $#values+1 ) {
		die "Number of columns are not identical at $chrom:$pos:$ref:$alt\n";
	}
	print OUT join("\t",@values);
	print OUT "\n";
}
close $in;
close OUT;


$cmd = "$bin --in $out.raw --out $out.norm";
print "$cmd\n";
print `$cmd`;

# Make SVM features
unless($model)
{
	my %valid = ();
	my %invalid = ();
	my $pos_count = 0;
	my $neg_count = 0;

	for my $bfile (@bfiles)
	{
		print "Reading positive examples from $bfile \n";
		my $in = openInFile($bfile);
		while(<$in>)
		{
                    next if ( /^#/ );  # skip lines that start with #
                    # Only use the first 5 columns
                    my ($chr, $pos, $id, $ref, $alt) = split;
                    $valid{"$chr:$pos:$ref:$alt"} = 1;
		}
		close($in);
	}

	if (@nfiles > 0)
	{
		for my $nfile (@nfiles)
		{
			print "Reading negative examples from $nfile \n";
	                my $in = openInFile($nfile);
		        while(<$in>)
                        {
                            next if ( /^#/ );  # skip lines that start with #
                            # Only use the first 5 columns
                            my ($chr, $pos, $id, $ref, $alt) = split;

                            $invalid{"$chr:$pos:$ref:$alt"} = 1;
                        }
                        close($in);
		}
	}

        my $in = openInFile($invcf);
	open(RST,"$out.norm") || die "Cannot open file $out.norm\n";
	open(SVM,">$out.svm") || die "Cannot open file $out.svm to write\n";
	open(LBL,">$out.labeled.svm") || die "Cannot open $out.labeled.svm to write\n";

	while(<$in>) {
		unless (/^#/)
		{
			my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info) = split(/[\t\r\n]+/);
			my @z = split(/[ \t\r\n]+/,<RST>);
			my $ln = "";

			for(my $i=0; $i < @names; ++$i) 
			{
				$ln .= " ".($i+1).":$z[$i]";
			}

			#if ($chr =~ /X/)
			#{
			#	print SVM "0 $ln\n";
			#}
			#elsif (defined($invalid{"$chr:$pos"}))
                        if (defined($invalid{"$chr:$pos:$ref:$alt"}))
			{
				print SVM "-1 $ln\n";
				if (rand()*100 <= $negsample)
				{
					print LBL "-1 $ln\n";
					$neg_count++;
				}
			}
			elsif (defined($valid{"$chr:$pos:$ref:$alt"}))
			{
                            my @filts = split(/;/,$filter);
                            if ( ( $filter eq "PASS" ) || ( $#filts < $numFilter ) )
                            {
				print SVM "1 $ln\n";
				if (rand()*100 <= $possample)
				{
					print LBL "1 $ln\n";
					$pos_count++;
				}
                            }
                            else
                            {
                                print SVM "0 $ln\n";
                            }
			}
			elsif ($filter ne "PASS" && $numFilter>0)
			{
				my @filts = split(/;/,$filter);
				if (@filts>=$numFilter)
				{
					print SVM "-1 $ln\n";
						if (rand()*100 <= $negsample)
						{
							print LBL "-1 $ln\n";
							$neg_count++;
						}
				}
				else
				{
					print SVM "0 $ln\n";
				}
			}
			else
			{
				print SVM "0 $ln\n";
			}
		}
	}
	close $in;

	unless ($keepData)
	{
		unlink("$out.raw");
		unlink("$out.norm");
	}

	close SVM;
	close LBL;

	print STDOUT "Positive samples: $pos_count, Negative samples: $neg_count\n";

	print STDOUT join("\t",@names)."\n";
#	my $gamma = 1/(scalar @names);

	$cmd = "$svmlearn -s 0 -t 2 $out.labeled.svm $out.svm.model";
	print "$cmd\n";
	print `$cmd`;

	$cmd = "$svmclassify $out.svm $out.svm.model $out.svm.pred";
	print "$cmd\n";
	print `$cmd`;

	unless ($keepData)
	{
		unlink("$out.svm");
		unlink("$out.labeled.svm");
	}
} # unless($model)

else
{
        my $in = openInFile($invcf);

	open(RST,"$out.norm") || die "Cannot open file $out.norm\n";
	open(SVM,">$out.svm") || die "Cannot open file $out.svm to write\n";

	while(<$in>)
	{
		unless (/^#/)
		{
			my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info) = split(/[\t\r\n]+/);
			my @z = split(/[ \t\r\n]+/,<RST>);
			my $ln = "";

			for(my $i=0; $i < @names; ++$i) 
			{
				$ln .= " ".($i+1).":$z[$i]";
			}
			print SVM "0 $ln\n";
		}
	}
	close $in;
	close SVM;

	$cmd = "$svmclassify $out.svm $model.svm.model $out.svm.pred";
	print "$cmd\n";
	print `$cmd`;

	unless ($keepData)
	{
		unlink("$out.raw");
		unlink("$out.norm");
		unlink("$out.svm");
	}
}

$in = openInFile($invcf);

if ( $out =~ /\.gz$/ )
{
    my $bindir = "$FindBin::Bin";
    open(VCF,"| $bindir/../bin/bgzip -c > $out") || die "Cannot open file\n";
}
else {
    open(VCF,">$out") || die "Cannot open file $out to write\n";
}
open(PRED,"$out.svm.pred") || die "Cannot open $out.svm.pred file to read\n";

while (<$in>)
{
	if (/^#/)
	{
		print VCF $_;
	}
	else
	{
		chomp;
		my (@F) = split;
		my $pred = <PRED>;
		chomp($pred);
		my $filter = "";

		if ($F[6] =~ /(INDEL\d+)/)
		{
			$filter = $1;
		}
		$F[7] .= ";$keyword=$pred";

		if ($pred > $cutoff)
		{
			if ($filter eq "")
			{
				$filter = "PASS";
			}
		}
		elsif ($filter eq "")
		{
			$filter = "SVM";
		}
		else
		{
			$filter .= ";SVM";
		}
		$F[6] = $filter;

		print VCF join("\t",@F)."\n";
	}
}

close $in;
close VCF;

unless ($keepData)
{
	unlink("$out.svm.pred");
	unlink("$out.svm.model");
}


#---------------------------------
# Subroutine for opening a file
# that checks if it has a .gz extension
#---------------------------------
sub openInFile
{
    my $filename = shift;

    die "Can't read $filename" unless( -f $filename and -r $filename);

    my $openResult = 0;

    local *IN;
    if ($filename =~ m/\.gz$/)
    {
        $openResult = open(IN,"gunzip -c $filename|")
    }
    else
    {
	$openResult = open(IN,$filename) || die "Cannot open $filename\n";
    }

    if($openResult)
    {
        return *IN;
    }
    die "Cannot open $filename\n";
    return undef;
}
