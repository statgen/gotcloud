#!/usr/bin/env perl
package gcGetOptions;

use warnings;
use Getopt::Long;
use Pod::Usage;
use File::Basename;
use Cwd 'abs_path';
use base qw/Exporter/;
use FindBin;
use lib "$FindBin::Bin/";
use hyunlib qw(getAbsPath getIntConf loadConf dumpConf setConf getConf ReadConfig parseKeyVal);

@EXPORT_OK = qw(gcpod2usage gcstatus gcGetOptions);

$podstr = "";
$statusstr = "";


## Advanced version of GetOptions specialized for gotCloud
sub gcGetOptions {
    my @arg = @_;
    my %htypes = ( "s" => "STR", "i" => "INT", "f" => "FLT" );
    my $man = 0;
    my $help = 0;
    my @opts = ("help|?",\$help,"man",\$man);
    my @keys = qw(help man);
    my @types = ("","");
    my @shorts = ("Print out brief help message","Print the full documentation in man page style");
    my @confnames = ("","");
    my @defaults = (0,0);
    my @isects = (0);  ## section indices
    my @tsects = ("Help Options");  ## section titles
    my $tsectlen = length($tsects[0]);
    my $main = "";

    my $confref;
    my $gcrootref;
    my $outdirref;

    ## Scan through the input arguments and assign the arguments to variables
    ## Also, detect special variables such as gcroot or conf
    for(my $i=0; $i < @_; ++$i) {
	if ( $arg[$i] =~ /^-/ ) {  ## this entry is not an argument but a description
	    if ( $arg[$i] =~ /^--/ ) {
		$arg[$i] =~ s/^-*//;
		push(@isects,$#keys+1);
		push(@tsects,$arg[$i]);
		$tsectlen = length($arg[$i]) if ( $tsectlen < length($arg[$i]) );
	    }
	    else {
		$arg[$i] =~ s/^-*//;
		$main = $arg[$i];
	    }
	}
	else {
	    my $opt = $arg[$i];
	    my ($ref,$short,$confname) = @{$arg[$i+1]};
	    my ($key,$type) = split(/=/,$opt);
	    $confname = "" unless ( defined($confname) );
	    my $typestr = defined($type) ? $htypes{$type} : "";
	    my $default;
	    if ( ref($ref) eq "ARRAY" ) {
		$short = "(Multiples) $short";
		$default = join(" ",@{$ref});
	    }
	    else {
		if ( defined($type) ) {
		    $default = ${$ref};
		}
		else {
		    $default = ${$ref} ? "ON" : "OFF";
		}
	    }
	    push(@keys,$key);
	    push(@opts,$opt);
	    push(@opts,$ref);
	    push(@types,$typestr);
	    push(@shorts,$short);
	    push(@confnames,$confname);
	    push(@defaults,$default);
	    ++$i;

	    if ( $key eq "conf" ) {
		die "Argument conf must be a string. Use 'conf=s' when specifying" unless ( $type eq "s");
		$confref = $ref;
	    }
	    elsif ( ( $key =~ /gcroot/ ) || ( $key =~ /gotcloudroot/ ) ) {
		die "Argument gcroot or gotcloudroot must be a string. Use 'gcroot=s' when specifying" unless ( $type eq "s" );
		$gcrootref = $ref;
	    }
	    elsif ( $key eq "outdir" ) {
		die "Argument outdir must be a string. Use 'outdir=s' when specifying" unless ( $type eq "s" );
		$outdirref = $ref;		
	    }
	}
    }

    ## perform getOptions to get the values
    my $ret = GetOptions(@opts);

    ## Create a custom man file in the case manual needs to be generated
    $podstr = "=pod\n\n=head1 NAME\n\n$0 - $main \n\n=head1 SYNOPSIS\n\n$0 [options]\n\n";
# General Options:\n";
#  -help             Print out brief help message [OFF]\n  -man              Print the full documentation in man page style [OFF]\n";
    my @values = ();
    for(my ($i,$j) = (0,0); $i < @keys; ++$i) {
	if ( ( $j <= $#isects ) && ( $i == $isects[$j] ) ) {
	    $podstr .= "\n $tsects[$j]:\n";
	    ++$j;
	}
	my $value;
	if ( ref($opts[$i+$i+1]) eq "ARRAY" ) {
	    $value = join(" ",@{$opts[$i+$i+1]});
	}
	else {
	    if ( $types[$i] ) {
		$value = ${$opts[$i+$i+1]};
	    }
	    else {
		$value = ${$opts[$i+$i+1]} ? "ON" : "OFF";
	    }
	}
	push(@values,$value);
	$podstr .= sprintf("  -%-20s%s [%s]\n","$keys[$i] $types[$i]",$shorts[$i],$values[$i]);
    }
    $podstr .= "\n=head1 OPTIONS\n\n=over 8\n\n=item B<-help>\n\nPrint a brief help message and exits\n\n=item B<-man>\n\nPrints the manual page and exits\n\n";
    for(my $i=0; $i < @keys; ++$i) {
	$podstr .= sprintf("  -%-17s%s [%s]\n","$keys[$i] $types[$i]",$shorts[$i],$values[$i]);
    }

    gcpod2usage(-verbose => 1, -exitval => 1) if ( $help );
    gcpod2usage(-verbose => 2) if ( $man );

    ## Read configuration file and override values from runtime arguments if needed
    if ( defined($confref) ) { ## If config option exists
	my @configs = split(' ',${$confref});  ## read configuration file
	my @confSettings;

	my $gcroot;
	if ( ( defined($gcrootref) ) && ( ${$gcrootref} ) ) {
	    $gcroot = ${$gcrootref};
	    push(@confSettings, "GOTCLOUD_ROOT = ".${$gcrootref});
	}
	else {
	    $gcroot = abs_path($FindBin::Bin);
	    $gcroot =~ s/\/bin\/*$//;
	    push(@confSettings, "GOTCLOUD_ROOT = $gcroot");
	}
	#die "gcroot = $gcroot\n";

	my $outdir;
	if ( defined($outdirref) ) {
	    $outdir = ${$outdirref};
	    push(@confSettings, "OUT_DIR = ".${$outdirref});
	}

	my ($scriptName, $scriptPath) = fileparse(abs_path($FindBin::Script));

	my %opts = (
	    phonehome => "$gcroot/scripts/gcphonehome.pl -pgmname GotCloud $scriptName",
	    pipelinedefaults => "$gcroot/bin/gotcloudDefaults.conf",
	    );
	push(@configs, $opts{pipelinedefaults});

	if ( loadConf(\@confSettings,\@configs,$verbose) ) {  ## load configurations
	    die "Failed to read configuration files @configs";
	}

	## iterate configuration variables and assign values
	for(my $i=0; $i < @keys; ++$i) {
	    if ( defined($confnames[$i]) && ( $confnames[$i] ) ) {
                my $argval;
                if ( ref($opts[$i+$i+1]) eq "ARRAY" ) {
                    $argval = join(" ",@{$opts[$i+$i+1]});
                }
                else {
                    #die "$keys[$i]\n" unless defined($opts[$i+$i+1]);
                    if ( defined($types[$i]) ) {
                        $argval = ${$opts[$i+$i+1]};
                    }
                    else {
                        $argval = ${$opts[$i+$i+1]}  ? "ON" : "OFF";
                    }
                }
		## check if the configuration value exists
		my $confval = getConf($confnames[$i]);
		if ( $confval ) { ## if configuration value exists
		    ## check if it was changed from the default value

		    #print STDERR "** $keys[$i] $argval $defaults[$i] $confval\n";
		    if ( $argval eq $defaults[$i] ) {
			## if default value was not changed and the configuration value exist, override
			if ( $types[$i] ) {
			    ${$opts[$i+$i+1]} = $confval;
			}
			else {
			    ${$opts[$i+$i+1]} = ( $confval eq "TRUE" ) ? 1 : "";
			}
		    }
                    else
                    {
                       # changed from default, set the configuration
                        setConf($confnames[$i], $argval);
                    }
		}
                else
                {
                    # Configuration was not set, so set the configuration
                    setConf($confnames[$i], $argval);
                }
	    }
	}
    }

    $statusstr = "Arguments in effect for $0:";
    my $line = "";
    @values = ();
    for(my ($i,$j) = (0,0); $i < @keys; ++$i) {
	if ( ( $j <= $#isects ) && ( $i == $isects[$j] ) ) {
	    $statusstr .= "\n$line" if ( $line );
	    $line = sprintf("  %-*s: ",$tsectlen+2,$tsects[$j]);
	    ++$j;
	}
	my $value;
	if ( ref($opts[$i+$i+1]) eq "ARRAY" ) {
	    $value = join(" ",@{$opts[$i+$i+1]});
	}
	else {
	    if ( $types[$i] ) {
		$value = ${$opts[$i+$i+1]};
	    }
	    else {
		$value = ${$opts[$i+$i+1]} ? "ON" : "OFF";
	    }
	}
	push(@values,$value);
	$line .= sprintf("  -%s [%s]","$keys[$i]",$values[$i]);
	if ( length($line) > 80 ) {
	    $statusstr .= "\n$line";
	    $line = sprintf("  %-*s  ",$tsectlen+2,"");
	}
    }
    $statusstr .= "\n$line\n";
    #print STDERR $statusstr;
    #die;
    
    return $ret;
}

sub gcpod2usage {
    ## Parse the input argument, same to what pod2usage does
    local($_) = shift;
    my %opts = ();
    ## Collect arguments
    if (@_ > 0) {
        ## Too many arguments - assume that this is a hash and
        ## the user forgot to pass a reference to it.
        %opts = ($_, @_);
    }
    elsif (!defined $_) {
	$_ = '';
    }
    elsif (ref $_) {
        ## User passed a ref to a hash
        %opts = %{$_}  if (ref($_) eq 'HASH');
    }
    elsif (/^[-+]?\d+$/) {
        ## User passed in the exit value to use
        $opts{'-exitval'} =  $_;
    }
    else {
        ## User passed in a message to print before issuing usage.
        $_  and  $opts{'-message'} = $_;
    }

    ## Temporarily write a POD document
    my $pid = $$;
    my @binpaths = split(/\//,$0);
    my $binname = pop(@binpaths);
    mkdir("/tmp/$pid");
    open(OUT,">/tmp/$pid/$binname") || die "Cannot open file\n";
    print OUT $podstr;
    close OUT;

    ## Modify the options to include -input, without exiting
    my $exitval = $opts{'-exitval'};
    $exitval = 0 unless ( defined($exitval) );
    $opts{'-exitval'} = "noexit";
    $opts{'-verbose'} = 0 unless defined($opts{'-verbose'});
    $opts{'-input'} = "/tmp/$pid/$binname";
 
    ## Call pod2usage function
    pod2usage(\%opts);
    #pod2usage({-exitval => "noexit", -input => "/tmp/$pid/$binname", -verbose => 2});
    unlink("/tmp/$pid/$binname");
    rmdir("/tmp/$pid");
    exit($exitval)  unless ($exitval eq 'noexit');
}

sub gcstatus {
    print STDERR $statusstr;
}

1;
