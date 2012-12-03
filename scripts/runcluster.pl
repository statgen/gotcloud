#!/usr/bin/perl
#################################################################
#
# Name:	runcluster.pl
#
# Description:
#   Use this to submit a command to the Sun Grid Engine
#   This seems to be necessary to overcome a bug in qrsh
#
# ChangeLog:
#   29 Nov 2012 tpg   Initial coding
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################
use strict;
use warnings;

my %opts = ();
$opts{verbose} = 0;    # Set manually as needed for development
$opts{log} = "";       # Maybe something like "/tmp/$0.log";

#   If the command has some left over legacy junk (sh -c cmd), remove it
if ($ARGV[0] eq 'sh') { shift(@ARGV); }
if ($ARGV[0] eq '-c') { shift(@ARGV); }

#   Build the command from our arguments  (might include | < or >)
my $cmd = join(' ', @ARGV);
if ($opts{verbose}) {
  print "Args are:\n";
  for (my $i=0; $i<=$#ARGV; $i++) { print " N=$i  '$ARGV[$i]'\n"; }
  print "End of Args\n";
  print "CMD=$cmd";
}
if ($opts{log} && open(OUT,'>>' . $opts{log})) {
  print OUT $cmd . "\n";
  close(OUT);
}

#   Qrsh fails: error: commlib error: got read error (closing "node002/shepherd_ijs/1")
#   so we try writing the command to a shell script, minimizing the role
#   that qrsh actually does
my $f = $ENV{HOME} . "/z$$.sh";
open(OUT, '>' . $f) || die "Unable to create script: $f:  $!\n";
print OUT "#!/bin/sh\n$cmd\n";
close(OUT);
chmod(0755, $f);
my $rc = 0xffff & system("qrsh $f");
unlink($f);
exit($rc);
