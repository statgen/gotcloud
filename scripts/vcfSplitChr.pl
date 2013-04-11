#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use IO::Zlib;
use File::Path qw(make_path);
use File::Basename;

my $in = "";
my $out = "";
# chrKey is what to replace in out with the chromsome number.
my $chrKey = "CHR";

my $result = GetOptions("in=s",\$in,
			"out=s",\$out,
			"chrKey=s",\$chrKey
                       );

my $usage = "Usage: perl [vcfSplitChr.pl] --in=[$in] --out=[$out] --chrKey[$chrKey]\n";

die "Error in parsing options\n$usage\n" unless ( ( $result ) && ( $in ) && ($out) && ($chrKey) ) ;

my $header = "";
my $gzFlag = ( $in =~ /\.gz$/ ) ? 1 : 0;

if ( $gzFlag ) {
    die "Cannot open file\n" unless ( -s $in );
    tie *IN, "IO::Zlib", $in, "rb";
}
else {
    open(IN,$in) || die "Cannot open file $in\n";
}


my $prevChr = -1;
while(<IN>)
{
    if ( /^#/ ) {
	$header .= $_;
        next;
    }
    my ($chr, $pos) = split(/[\t\n]+/);

    if($chr ne $prevChr)
    {
        if($prevChr ne -1)
        {
            # Close the previous chromosome file.
            if ( $gzFlag )
            {
                untie *OUT;
            }
            else
            {
                close OUT;
            }
        }
        # Open a new chromosome file.
        my $outFile = $out =~ s/$chrKey/$chr/rg;
        make_path(dirname ($outFile));
        print "$outFile\n";

        if ( $gzFlag )
        {
            tie *OUT, "IO::Zlib", "$outFile", "wb" || die "Cannot open file\n";
        }
        else
        {
            open(OUT,">$outFile") || die "Cannot open file\n";
        }
        print OUT $header;
        $prevChr = $chr;
    }
    # Write to file.
    print OUT $_;
}

# Close the output file.
if ( $gzFlag ) {
    untie *IN;
    untie *OUT;
}
else {
    close IN;
    close OUT;
}
