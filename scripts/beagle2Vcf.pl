#!/usr/bin/perl -w

#################################################################
# beagle2vcf.pl
# convert BEAGLE output files into LD-aware VCFs
#################################################################

use strict;
use Getopt::Long;
use IO::Zlib;

my $beagle = "";  # Beagle
my $invcf = ""; 
my $outvcf = "";
my $filterflag = "";
my $convFlag = "";

my $result = GetOptions("beagle=s",\$beagle,
			"invcf=s",\$invcf,
                        "outvcf=s",\$outvcf,
			"conv",\$convFlag,
			"filter",\$filterflag
    );

my $usage = "Usage: perl beagle2vcf.pl --beagle=[$beagle] --invcf=[$invcf] --outvcf=[$outvcf]\n";

die "Error in parsing options\n$usage\n" unless ( ($result) && ($beagle) && ($invcf) && ($outvcf) );

tie *HAP, "IO::Zlib", "$beagle.phased.gz", "rb" || die "Cannot open HAP file\n";
tie *DOSE, "IO::Zlib", "$beagle.dose.gz", "rb" || die "Cannot open DOSE file\n";
tie *PROB, "IO::Zlib", "$beagle.gprobs.gz", "rb" || die "Cannot open GPROBS file\n";
open(R2,"$beagle.r2") || die "Cannot open $beagle.r2 file\n";
if ( $outvcf =~ /\.gz$/ ) {
    tie *OUT, "IO::Zlib", $outvcf, "wb" || die "Cannot open $outvcf for writing\n";
}
else {
    open(OUT,">$outvcf") || die "Cannot open $outvcf for writing\n";
}

if ( $invcf =~ /\.gz$/ ) {
    tie *IN, "IO::Zlib", $invcf, "rb" || die "Cannot open $invcf for reading\n";
}
else {
    open(IN,$invcf) || die "Cannot open $invcf for reading\n";

}

my @iIDs = ();
my $prevMetaKey = "";
while(<IN>) {
    if ( /^##/ ) {
	if ( /^##([^=]+)=(.+)$/ ) {
	    my ($key,$val) = ($1,$2);
	    if ( ( $key ne "INFO" ) && ( $prevMetaKey eq "INFO" ) ) {
		print OUT "##INFO=<ID=BAVPOST,Number=1,Type=Float,Description=\"Average posterior probability from beagle\">\n";
		print OUT "##INFO=<ID=BRSQ,Number=1,Type=Float,Description=\"Genotype imputation quality estimate from beagle\">\n";
	    }
	    $prevMetaKey = $key;
	    print OUT $_;
	}
	else {
	    die "Cannot recogize Meta Line $_\n";
	}
    }
    elsif ( /^#CHROM/ ) {
	print OUT "##FORMAT=<ID=BD,Number=1,Type=Float,Description=\"Genotype dosage from beagle\">\n";

	my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@ids) = split(/[\t\n\r]/);
	my ($hType,$hMarker,@hIDs) = split(/\s+/,<HAP>);
	my ($dMarker,$dAlleleA,$dAlleleB,@dIDs) = split(/\s+/,<DOSE>);
	my ($pMarker,$pAlleleA,$pAlleleB,@pIDs) = split(/\s+/,<PROB>);

	my %hid2idx = ();
	for(my $i=0; $i < @ids; ++$i) {
	    $hid2idx{$ids[$i]} = $i;
	}

	print OUT join("\t",($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format));
	for(my $i=0; $i < @dIDs; ++$i) {
	    die "IDs do not match between .phased.gz and .dose.gz files" unless ( ($dIDs[$i] eq $hIDs[$i*2]) && ($dIDs[$i] eq $hIDs[$i*2+1]) && ( $dIDs[$i] eq $pIDs[$i*3] ) && ( $dIDs[$i] eq $pIDs[$i*3+1] ) && ( $dIDs[$i] eq $pIDs[$i*3+2] ) );
	    if ( defined($hid2idx{$dIDs[$i]}) ) {
		push(@iIDs,$hid2idx{$dIDs[$i]});
		print OUT "\t".($dIDs[$i]);
	    }
	    else {
		die "Cannot find $dIDs[$i] from the input VCF file\n";
	    }
	}
	print OUT "\n";
    }
    else {
	my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@g) = split(/[\t\n\r]/);
	next if ( ($filterflag) && ( $filter ne "PASS" ) );

	my ($hType,$hMarker,@h) = split(/\s+/,<HAP>);
	my ($dMarker,$dAlleleA,$dAlleleB,@d) = split(/\s+/,<DOSE>);
	my ($pMarker,$pAlleleA,$pAlleleB,@p) = split(/\s+/,<PROB>);
	my ($rMarker,$r2) = split(/\s+/,<R2>);

	die "ERROR: $id $hMarker $dMarker $rMarker $chrom:$pos\n" if ( ( $hMarker ne "$chrom:$pos")  || ( $dMarker ne $hMarker ) || ( $rMarker ne $hMarker ) );
	$ref = uc($ref);
	$alt = uc($alt);
	my ($a1,$a2) = ($ref,$alt);
	my ($n1,$n2) = (0,1);
	if ( $convFlag ) {
	    ($a1,$a2) = ("A","C");
	}
	elsif ( length($alt) > 1 ) {
	    ($a1,$a2) = split(/,/,$alt);
	    ($n1,$n2) = (1,2);
	}

	my $AP = 0;
	my @ACs = (0,0,0);
	my $AN = 0;
	my @phases = ();
	foreach my $iID (@iIDs) {
	    my $g1 = ($h[$iID*2] eq $a1) ? $n1 : $n2;
	    my $g2 = ($h[$iID*2+1] eq $a1) ? $n1 : $n2;
	    push(@phases,"$g1|$g2");
	    $AN += 2;
	    ++$ACs[$g1];
	    ++$ACs[$g2];
	    my $geno = ($a1 eq $h[$iID*2]) ? ( ($a1 eq $h[$iID*2+1]) ? 0 : 1 ) : ( ($a1 eq $h[$iID*2+1]) ? 1 : 2);
#	    die "$i $geno $#p\n" unless defined($p[$i/2*3+$geno]);
	    $AP += $p[$iID*3+$geno]/($#d+1);
	}
	#my $AF = ($ACs[2] > 0) ? sprintf("%.6lf,%6lf",$ACs[1]/$AN,$ACs[2]/$AN) : sprintf("%.6lf",$ACs[1]/$AN);
	my $AC = ($ACs[2] > 0) ? "$ACs[1],$ACs[2]" : $ACs[1];
	$AP = sprintf("%.3lf",$AP);
	$r2 = sprintf("%.3lf",$r2);
	print OUT join("\t",($chrom,$pos,$id,$ref,$alt,$qual,$filter));
	print OUT "\t";

	my @infos = split(/;/,$info);
	my @newinfos = ();
	foreach my $s (@infos) {
	    my ($key,$val) = split(/=/,$s);
	    if ( $key eq "AN" ) {
		$val = $AN;
	    }
	    elsif ( $key eq "AC" ) {
		$val = $AC;
	    }
	    #elsif ( $key eq "AF" ) {
	#	$val = $AF;
	#    }
	    if ( defined($val) ) {
		push(@newinfos,"$key=$val");
	    }
	    else {
		push(@newinfos,$key);
	    }
	}
	push(@newinfos,"BAVGPOST=$AP");
	push(@newinfos,"BRSQ=$r2");
	print OUT join(";",@newinfos);

	my @formats = split(/:/,$format);
	my $GTidx = -1;
	for(my $i=0; $i < @formats; ++$i) {
	    $GTidx = $i if ($formats[$i] eq "GT");
	}
	die "Cannot find GT tag in $format" if ($GTidx < 0 );

	print OUT "\t$format:BD";

	for(my $i=0; $i < @iIDs; ++$i) {
	    if ( $g[$iIDs[$i]] eq "./." ) {
		print OUT "\t";
		for(my $j=0; $j < @formats; ++$j) {
		    if ( $formats[$j] eq "GT" ) {
			print OUT $phases[$i];
		    }
		    elsif ( ( $formats[$j] eq "PL" ) || ( $formats[$j] eq "GL" ) ) {
			print OUT "0,0,0";
		    }
		    elsif ( ( $formats[$j] eq "DP" ) || ( $formats[$j] eq "GD" ) ) {
			print OUT "0";
		    }
		    elsif ( $formats[$j] eq "AD" ) {
			print OUT "0,0";
		    }
		    else {
			print OUT ".";
		    }
		    print OUT ":";
		}
		print OUT $d[$iIDs[$i]];
	    }
	    else {
		my @gvals = split(/:/,$g[$iIDs[$i]]);
		print OUT "\t";
		for(my $j=0; $j < @gvals; ++$j) {
		    if ( $GTidx == $j ) {
			print OUT $phases[$i];
		    }
		    else {
			print OUT $gvals[$j];
		    }
		    print OUT ":";
		}
		print OUT $d[$iIDs[$i]];
	    }
	}
	print OUT "\n";
    }
}
close R2;

if ( $outvcf =~ /\.gz$/ ) {
    untie *OUT;
}
else {
    close OUT;
}
if ( $invcf =~ /\.gz$/ ) {
    untie *IN;
}
else {
    close IN;
}
untie *HAP;
untie *DOSE;
untie *PROB;
