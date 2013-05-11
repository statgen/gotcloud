#!/usr/bin/perl -I..
#################################################################
#
# Test case for Conf.pm
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; See http://www.gnu.org/copyleft/gpl.html
################################################################
use strict;
use warnings;
use File::Basename;
use Data::Dumper;
require Conf;

our %CONF_HASH = ();                # Defined in Conf
my ($me, $scriptdir, $mesuffix) = fileparse($0, '\.t');

my $defconf = 'does_not_exist';
my $e = loadConf($defconf, 1);
warn "Found $e errors reading conf '$defconf'\n";
print Dumper(\%CONF_HASH) . "\n";

$defconf = shift;
$e = loadConf($defconf, 1);
warn "Found $e errors reading conf '$defconf'\n";
print Dumper(\%CONF_HASH) . "\n";

$ENV{CONF_PATH} = $scriptdir . '../t';
$e = loadConf($defconf, 1);
warn "Found $e errors reading conf '$defconf' and using CONF_PATH=" . $ENV{CONF_PATH} . "\n";
print Dumper(\%CONF_HASH) . "\n";
