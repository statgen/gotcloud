####################################################################
#
#   Regression testing for the aligner
#
###################################################################
use Test::More tests => 12;
use strict;
use Cwd;

#   Figure out where GotCloud is installed
#   This assumes the code is run in gotcloud/t/conf or from gotcloud (make test)
my $here = getcwd;
my $basepath = $here;
if (! -d 'bin') {
    chdir('../..') || die "Unable to 'CHDIR ../..' : $!\n";
    $basepath = getcwd;
    chdir($here) || die "Unable to 'CHDIR $here' : $!\n";
}
if (! -d "$basepath/t") { die "I got lost trying to find top of GotCloud\n"; }
chdir("$basepath/t/align");          # CD to my directory


###################################################################
#   Run aligner, get results, check results. Rinse. Repeat.
###################################################################
my ($aref, $f);
my $VERBOSE=$ARGV[0];           # If arg=0, no show but show last lines. If 1 show all

#
#   Run the aligner (always does --out /tmp --dry-run)
#       input - options to pass to program
#       returns reference to array of STDOUT and STDERR from the execution
sub run_align {
    my ($conf, $opts) = @_;
    if (! defined($opts)) { $opts = ''; }
    my $c = "../../bin/align.pl -conf $conf $opts -outdir /tmp --dry-run";
    my @r = split("\n", `$c 2>&1`);
    return \@r;
}

#   Show a line from the results
#       n - display line N from @$aref
sub show {
    if ($VERBOSE) { warn "  line[$_[0]]=$aref->[$_[0]]"; }
}

$f = '/dev/null';
$aref = run_align($f);
#warn "\n" . $f . "\n";
like ($aref->[0], qr/INDEX_FILE was not specified/, 'must specify INDEX_FILE');
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
like ($aref->[0], qr/Created .+align_Sample2.Makefile/, 'Makefile 2 created');
show(0);
like ($aref->[1], qr/Created .+align_Sample1.Makefile/, 'Makefile 1 created');
show(1);

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
    warn "\n\n\n############# Here is output #####################\n";
    warn join("\n", @$aref);
}
