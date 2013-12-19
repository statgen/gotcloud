#!/usr/bin/perl
use strict;
use warnings;
use IO::File;
use IO::Zlib;
use Getopt::Long;
use File::Basename;
use Cwd;
use Cwd 'abs_path';
#################################################################
#
# Name: vcfMerge.pl
#
# Description:
#   Simple merge of vcfs.
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################

my @vcfs = @ARGV;

# Loop through and output the first file.

if($#vcfs < 0)
{
    die "vcfMerge.pl called without any VCF files.\n";
}

# Process the VCFs in order.
for(my $i=0; $i < @vcfs; ++$i)
{
    my $vcf = $vcfs[$i];
    my $fh;
    if ( $vcf =~ /\.gz$/ ) {
	$fh = new IO::Zlib;
	$fh->open($vcf, "rb") || die "Cannot open $vcf\n";
    }
    else {
	$fh = new IO::File $vcf, "r" || die "Cannot open $vcf\n";
    }

    my $line = $fh->getline();
    while(defined $line)
    {
        if($line =~ /^#/)
        {
            print $line if ($i == 0);
        }
        else
        {
            print $line;
        }
	$line = $fh->getline();
    }
    undef $fh;
}
