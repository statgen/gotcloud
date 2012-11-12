#!/usr/bin/perl -w

use strict;

die "Arguments @ARGV cannot be recognized\n" unless ($#ARGV == 1);
my ($vcf1,$vcf2) = @ARGV;

open(IN1,$vcf1) || die "Cannot open $vcf1\n";
while(<IN1>) {
    if ( /^##/ ) {
	print $_;
    }
    else {
	last;
    }
}
open(IN2, $vcf2) || die "Cannot open $vcf2\n";
while(<IN2>) {
    if ( /^##/ ) {
    }
    else {
	print $_;
	last;
    }
}
while(<IN1>) {
    my @F1 = split(/[\t\r\n]/);
    my @F2 = split(/[\t\r\n]/,<IN2>);
    die "VCF files do not match positions at $F1[0]:$F1[1] vs $F2[0]:$F2[1]\n" unless ( $F1[1] == $F2[1] );
    print join("\t",@F1[0..7]);
    print "\t";
    print join("\t",@F2[8..$#F2]);
    print "\n";
}
close IN1;
close IN2;
