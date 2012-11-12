#!/usr/bin/perl -w

use strict;
use IO::File;
use IO::Zlib;
use Getopt::Long;

my $invcf = "";
my $out = "";
my $indexf = "";
my $nofilterFlag = "";

my $optResult = GetOptions("invcf=s",\$invcf,
			   "out=s",\$out,
			   "index=s",\$indexf,
			   "nofilter",\$nofilterFlag
    );

my %hIdPop = ();
my %hPops = ();
open(IN,$indexf) || die "Cannot open file $indexf\n";
while(<IN>) {
    my ($id,$mpop) = split;
    my @mpops = split(/,/,$mpop);
    foreach my $pop (@mpops) {
	$hIdPop{$id}{$pop} = 1;
	unless (defined($hPops{$pop})) {
	    $hPops{$pop} = 1;
	}
    }
}
close IN;
my @pops = sort keys %hPops;

my $gzFlag = ( $invcf =~ /\.gz$/ ) ? 1 : 0;
if ( $gzFlag ) {
    die "Cannot open file $invcf\n" unless ( -s $invcf );
    tie *IN, "IO::Zlib", $invcf, "rb";
}
else {
    open(IN,$invcf) || die "Cannot open $invcf\n";
}

my @fds = ();
foreach my $pop (@pops) {
    if ( $gzFlag ) {
	my $fh = new IO::Zlib;
	$fh->open("$out.$pop.vcf.gz", "wb");
	push(@fds,$fh);
    }
    else {
	my $fh = new IO::File "$out.$pop.vcf", "w";
	push(@fds,$fh);
    }
}

my @iids = ();
for(my $cnts=0;<IN>;++$cnts) {
    print STDERR "Processing $cnts lines...\n" if ( $cnts % 100000 == 0 );
    if ( /^#/ ) {
	if ( /^#CHROM/ ) {
	    my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@ids) = split(/[\t\n]/);
	    my @rids = ();
	    for(my $i=0; $i < @pops; ++$i) {
		push(@iids,[]);
		push(@rids,[]);
	    }

	    for(my $j=0; $j < @ids; ++$j) {
		for(my $i=0; $i < @pops; ++$i) {
		    if ( defined($hIdPop{$ids[$j]}{$pops[$i]}) ) {
			push(@{$iids[$i]},$j);
			push(@{$rids[$i]},$ids[$j]);
		    }
		    else {
#			die "$pops[$i] $ids[$j]\n";
		    }
		}
	    }

	    #die join("\n",@{$rids[0]});
	    
	    for(my $i=0; $i < @pops; ++$i) {
		$fds[$i]->print("$chrom\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format\t".join("\t",@{$rids[$i]})."\n");
	    }
	}
	else {
	    foreach my $fd (@fds) {
		$fd->print($_);
	    }
	}
    }
    else {
	my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@genos) = split(/[\t\n]/);
	next if ( ( $nofilterFlag eq "" ) && ( $filter ne "PASS" ) );

	my @infos = split(/;/,$info);
	my %hinfos = ();
	foreach my $info (@infos) {
	    my ($key,$val) = split(/=/,$info);
	    $hinfos{$key} = $val;
	}
	
	for(my $i=0; $i < @pops; ++$i) {
	    my $NS = 0;
	    my @ACs = (0,0,0);
	    for(my $j=0; $j < $#{$iids[$i]}+1; ++$j) {
		if ( $genos[$iids[$i]->[$j]] =~ /^(\d+)[\/\|](\d+):(\d+):/ ) {
		    if ( $3 > 0 ) {
			++$NS;
			++$ACs[$1];
			++$ACs[$2];
		    }
		}
		else {
		    die "Cannot recognize $chrom:$pos - ($i,$j) - $iids[$i]->[$j] - $#genos - $genos[$iids[$i]->[$j]]\n";
		}
	    }

	    if ( ( $ACs[1] > 0 ) || ( $ACs[2] > 0 ) ) {
		my @newinfos = ();
		foreach my $key (sort keys %hinfos) {
		    if ( $key eq "NS" ) {
			push(@newinfos,"NS=$NS");
		    }
		    elsif ( $key eq "AC" ) {
			if ( $ACs[2] > 0 ) {
			    push(@newinfos,"AC=$ACs[1],$ACs[2]");
			}
			else {
			    push(@newinfos,"AC=$ACs[1]");
			}
		    }
		    elsif ( $key eq "AN" ) {
			push(@newinfos,"AN=".($NS*2));
		    }
		    else {
			push(@newinfos,$key."=".$hinfos{$key});
		    }
		}

		$fds[$i]->print("$chrom\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t".join(";",@newinfos)."\t$format");
		for(my $j=0; $j < $#{$iids[$i]}+1; ++$j) {
		    $fds[$i]->print("\t".$genos[$iids[$i]->[$j]]);
		}
		$fds[$i]->print("\n");
	    }
	}
    }
}
if ( $invcf =~ /\.gz$/ ) {
    untie *IN;
}
else {
    close IN;
}

for(my $i=0; $i < @pops; ++$i) {
    $fds[$i]->close();
}
