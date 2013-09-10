####################################################################
#
#   Regression testing for Conf.pm
#
#   If you need to see as much as possible, do
#   perl $0 1       # No warning data shown
#   perl $0 2       # Dump of all warnings at end to STDOUT
#   perl $0 4       # Dump of all warnings and more at end to STDOUT
#
###################################################################
no strict;
use Test::More tests => 19;
use Cwd;

#   We can either run this from the regression directory or t/conf
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

push @INC,"$gcroot/bin";
require Conf;
chdir("$gcroot/regression/t/conf");          # CD to my directory

#   Capture all warn output in @Warns so we can analyze it
my @Warns = ();
my $WarnsAsString = '';
my $DEBUG;
local $SIG{__WARN__} = sub {
    $l = scalar(@Warns) . ' : ' . $_[0];
    push @Warns, $l;
    $WarnsAsString .= $l;
};

#   Array of 'file' of configuration settings
my @confSettings = ("GOTCLOUD_ROOT = $basepath", "OUT_DIR = /tmp");
my @configs = ();
my $gc_defconf = "$gcroot/bin/gotcloudDefaults.conf"; # Default conf for GC
#
#   VERBOSE settings:
#       0       nothing shown
#       >=1     processing activity shown
#       >1      Die just does warn and returns ''  (for testing)
#       >=3     config entries before and after substitutions written to STDERR (not warn)
#       >3      parse of key=value shown
#
#   Setting verbose to anything > 2 will cause tests to fail, but sometimes you gotta
my $verbose = 2;                    # Force to 2, else counts in #Warns[] are off and dies

###################################################################
#   Test basic mechanics of config files
###################################################################
if (@ARGV) {                        # If argument provided, shown warns, maybe set version
    $DEBUG++;
    if ($ARGV[0] =~ /^\d+$/) { $verbose = $ARGV[0]; }
}
my $f;
my $r;
my @a;

#
#   $r = newconf('01.conf' [, otherconfs]);
#   Load a configuration file, sets @Warns, uses other global variables
#
sub newconf {
    $f = $_[0];
    @a = @_;
    @Warns = ();
    return loadConf(\@confSettings, \@a, $verbose);
}


###################################################################
#   Begin regression test
###################################################################
$r = newconf('01.conf');
ok($r ne 0, "Load '$f' failed as expected, some things set");
like ($Warns[2], qr/Unable to parse config line/, 'As expected, parse failed');
like ($Warns[2], qr/this is a bad line/, 'Show what failed');

$r = getConf('a');
ok($r eq 'B', "a=B as expected");
$r = getConf('b');
ok($r eq 'B.top', "a=B.top, substitution worked");
$r = getConf('c');
like ($r, qr/blanks on/, 'Blanks around = OK');
$r = getConf('ccccccccc');
like ($r, qr/end$/, 'Blank at end');
$r = getConf('d');
like ($r, qr/end.notice/, 'See imbedded blank');
$r = getConf('enotdefined');
ok($r eq '', "enotdefined= has no value");

setConf('a', 'NewB');
$r = getConf('a');
ok($r eq 'NewB', "Changed a to NewB as expected");

$r = getConf('mustbehere', 1);
ok($r eq '', "failed required key as expected for testing");
like ($Warns[4], qr/key 'mustbehere' .+ not found/, 'warning for required found');

$r = newconf($gc_defconf);
ok($r eq 0, "Load '$f' successful");
$r = getConf('AS');
ok($r eq NCBI37, "Override of AS not successful ($r)");

$r = newconf('02.conf', $gc_defconf);
ok($r eq 0, "Loads successful");
$r = getConf('AS');
ok($r eq NewNCBI37, "Override of AS successful ($r)");

$r = newconf($gc_defconf, '02.conf');
ok($r eq 0, "Loads successful");
$r = getConf('AS');
ok($r eq NCBI37, "Override of AS not successful ($r)");

push @confSettings, "AS = AnotherNCBI37";
$r = newconf($gc_defconf);
$r = getConf('AS');
ok($r eq AnotherNCBI37, "Override of AS from commandline successful ($r)");


#   If user wanted to see all captured warnings, show them now
if (! $DEBUG) { print "\n\n";  exit; }
print "\n\n\n########## Dump of all WARNINGS as LINENUM : MESSAGE ##########\n" .
    $WarnsAsString .
    "\n\n";

