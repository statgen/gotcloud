#!/usr/bin/perl

use FindBin qw($Bin);
use lib qq{$Bin/../t/tests}, qq{$Bin/../lib/perl5};

use Modern::Perl;

use Test::GotCloud;
use Test::GotCloud::Util;
use Test::GotCloud::Umake::Makefile::Parser;
use Test::GotCloud::Umake::Makefile::Target;

Test::Class->runtests;
