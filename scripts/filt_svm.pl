#!/usr/bin/perl -w
use strict;


open(IN, $ARGV[0]);

my $thres = $ARGV[1];

while(<IN>)
{
	if (/^#/)
	{
		print $_;
	}
	else
	{
		chomp;
		my $filter = "";
		my ($chr,$pos,$id,$ref,$alt,$qual,$filt,$info) =  split;

		if ($filt =~ /INDEL5/)
		{
			$filter = "INDEL5";
		}
		
		my (@infos) = split(/;/,$info);

		foreach my $inf (@infos)
		{
			my ($fld, $val) = split(/=/,$inf);
			if ($fld eq "SVM")
			{
				if ($val > $thres)
				{
					if ($filter eq "")
					{
						$filter = "PASS";
					}
				}
				elsif ($filter eq "")
				{
					$filter = "SVM";
				}
				else
				{
					$filter .= ";SVM";
				}
			}
		}
		print "$chr\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\n";
	}
}
