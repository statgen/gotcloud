#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Cwd;
use FindBin;
use lib "$FindBin::Bin";

my $man = 0;
my $help = 0;
my $vcf = "";
my $win = 20000;
my $overlap = 2000;
my $out = "";
my $njobs = 10;
my $nosingle = "";
my $ignoreFilter = "";

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions("help|?" => \$help, 
	   "man" => \$man,
	   "vcf=s",\$vcf,
	   "out=s",\$out,
	   "win=i",\$win,
	   "overlap=i",\$overlap,
	   "njobs=i",\$njobs,
	   "nosingle",\$nosingle,
	   "ignore-filter",\$ignoreFilter,
    ) || pod2usage(2);

pod2usage(1) if $help;

pod2usage(-verbose => 2) if $man;

my $bindir = "$FindBin::Bin";
my $bgzip = "$bindir/../bin/bgzip";
my $tabix = "$bindir/../bin/tabix";

unless ( ( $vcf ) && ( $out ) ) {
    print STDERR "ERROR: Missing required option\n";
    pod2usage(2);
}

die "Cannot open $vcf for reading\n" unless ( -s $vcf );

die "Input VCF must be bgzipped and tabixed\n" unless ( $vcf =~ /\.gz$/ );

unless ( -s "$vcf.tbi" ) {
    print STDERR "$vcf is not tabixed. Running tabix..\n";
    my $cmd = "tabix -pvcf $vcf\n";
    #print "$cmd\n"; print `$cmd`;
    &forkExecWait($cmd);
    die "Cannot tabix $vcf\n" unless ( -s "$vcf.tbi" );
}

my @chrs = ();
open(IN,"$tabix -l $vcf|") || die "Cannot run $tabix -l $vcf";
while(<IN>) {
    chomp;
    push(@chrs,$_);
}
close IN;
my $exit = $? >> 8;
die "ERROR: vcfSplit4.pl, failed to run tabix on $vcf, exit code: $exit\n" if $exit;

open(OUT,">$out.list") || die "Cannot open file\n";
my $num = 1;
foreach my $chr (@chrs) {
    print STDERR "Processing chr$chr..\n";
    my $prev = -1;
    my $prevend = 0;
    my $pos = 0;

    ## First, do not bgzip it
    my @outs = ();
    while( $prev < $pos ) {
	$prev = $pos;
	my $cmd = "($tabix -H $vcf; $tabix $vcf $chr:$pos | "
            . "perl -nale 'print if \$F[1] >= $pos' | " # Tabix might print long variants which start shortly before $pos. Remove them.
            . ($ignoreFilter ? "" : " grep -w PASS |")
            . ($nosingle ? " grep -v \"AC=1;\" |" : "")
            . " head -n $win | sed s/PL3/PL/g) > $out.$num.vcf";
	#print "$cmd\n"; print `$cmd`;
	&forkExecWait($cmd);

	$pos = `tail -n $overlap $out.$num.vcf | grep -v ^# | head -1 | cut -f 2`;
	die "Cannot find pos\n" unless ( defined($pos) );
	chomp $pos;

	my $beg = `grep -v ^# $out.$num.vcf | head -1 | cut -f 2`;
	chomp $beg;

	my $end = `tail -n 1 $out.$num.vcf | cut -f 2`;
	chomp $end;

	if ( $prevend == $end ) {
	    unlink("$out.$num.vcf");
	    print STDERR "*** Redundant: $num\t$chr\t$beg\t$end\t$out.$num.vcf.gz\n";
	}
	else {
	    print OUT "$num\t$chr\t$beg\t$end\t$out.$num.vcf.gz\n";
	    print STDERR "$num\t$chr\t$beg\t$end\t$out.$num.vcf.gz\n";
	    push(@outs,"$out.$num.vcf");
	    ++$num;
	}
	$prevend = $end;
    }

    ## Second bgzip them
    open(MAK,">$out.Makefile") || die "Cannot open file\n";
    print MAK ".DELETE_ON_ERROR:\n\n";
    print MAK "all: ".join(".gz ",@outs).".gz\n\n";
    for(my $i=0; $i < @outs; ++$i) {
	print MAK "$outs[$i].gz: $outs[$i]\n";
	print MAK "\t$bgzip $outs[$i]\n\n";
    }
    close MAK;

    my $cmd = "make -f $out.Makefile -j $njobs\n";
    &forkExecWait($cmd);
    #print "$cmd\n"; print `$cmd`;
}
close OUT;

sub forkExecWait {
    my $cmd = shift;
    #print "forkExecWait(): $cmd\n";
    my $kidpid;
    if ( !defined($kidpid = fork()) ) {
	die "Cannot fork: $!";
    }
    elsif ( $kidpid == 0 ) {
	exec($cmd);
	die "Cannot exec $cmd: $!";
    }
    else {
	waitpid($kidpid,0);
    }
}
