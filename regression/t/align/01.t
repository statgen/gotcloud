####################################################################
#
#   Regression testing for the aligner
#
###################################################################
use Test::More tests => 13;
use strict;
use Cwd;

#   We can either run this from the regression directory or '.'
my $here = getcwd;
my $basepath = $here;
my $gcroot;
for ('..', '../../..') {
    if (-d "$_/regression") {
        chdir($_);
        $gcroot = getcwd();
        last;
    }
}

#   Last check, do we know where we are
if (! $gcroot) {
    die "Unable to find GotCloud. Run the regression bucket like this:\n" .
        "  cd PATH/gotcloud/regression\n" .
        "  perl Makefile.PL\n" .
        "  make test\n";
}

my $tmpdir = $gcroot . '/regression/tmp';
my $align = "$gcroot/bin/align.pl";
my $alignopts = "-outdir $tmpdir --dry-run --gotcloudroot $gcroot";
chdir("$gcroot/regression/t/align");         # CD to my directory

###################################################################
#   Run aligner, get results, check results. Rinse. Repeat.
###################################################################
my ($aref, $f);
my $VERBOSE=$ARGV[0];           # If arg=0, no show but show last lines. If 1 show all
#$VERBOSE=1;
my $alloutput = '';
#
#   Run the aligner
#       input - options to pass to program
#       returns reference to array of STDOUT and STDERR from the execution
sub run_align {
    my ($conf, $opts) = @_;
    if (! defined($opts)) { $opts = ''; }
    my $c = "$align -conf $conf $opts $alignopts";
    my $lines = `$c 2>&1`;
    $alloutput .= "################ $conf output ################\n" . $lines . "\n";
    my @r = split("\n", $lines);
    return \@r;
}

#   Show a line from the results
#       n - display line N from @$aref
sub show {
    if ($VERBOSE) { warn "  line[$_[0]]=$aref->[$_[0]]"; }
}

#   Start by cleaning out the temp directory
system("rm -rf $tmpdir");

$f = '/dev/null';
$aref = run_align($f);
#warn "\n" . $f . "\n";
like ($aref->[0], qr/FASTQ_LIST was not specified/, 'must specify FASTQ_LIST');
show(0);

$f = '01.conf';
$aref = run_align($f);
#warn "\n" . $f . "\n";
like ($aref->[0], qr/required REF/, 'must specify REF');
show(0);
like ($aref->[1], qr/required DBSNP_VCF/, 'Bad REF leads to bad DBSNP_VCF');
show(1);
like ($aref->[2], qr/required HM3_VCF/, 'Bad REF leads to bad HM3_VCF');
show(2);
like ($aref->[$#$aref], qr/due to required file/, 'Missing files');
show($#$aref);

$f = '04.conf';
$aref = run_align($f);
#warn "\n" . $f . "\n";
like ($aref->[0], qr/required DBSNP_VCF/, 'must specify DBSNP_VCF');
show(0);

$f = '05.conf';
$aref = run_align($f);
#warn "\n" . $f . "\n";
like ($aref->[0], qr/required HM3_VCF/, 'must specify HM3_VCF');
show(0);

$f = '06.conf';
$aref = run_align($f);
#warn "\n" . $f . "\n";
like ($aref->[0], qr/Created .+align_Sample1.Makefile/, 'Makefile 1 created');
show(0);
like ($aref->[1], qr/Created .+align_Sample2.Makefile/, 'Makefile 2 created');
show(1);
like ($aref->[2], qr/Created .+align_Sample3.Makefile/, 'Makefile 3 created');
show(2);

$f = '08.conf';
$aref = run_align($f);
#warn "\n" . $f . "\n";
like ($aref->[0], qr/Missing required exes/, 'Missing required exes');
show(0);
like ($aref->[1], qr/SAMTOOLS_EXE,/, 'samtools missing');
show(1);
like ($aref->[2], qr/BAM_EXE,/, 'bam missing');
show(1);


if (defined($VERBOSE)) {
    warn "\n\n\n############# Here is output #####################\n" . $alloutput;
}
