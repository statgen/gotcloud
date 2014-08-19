#!/usr/bin/env perl

use FindBin qw($Bin);
use lib qq($Bin/../lib/perl5);

use Modern::Perl;
use GotCloud::Status;

GotCloud::Status->run;
