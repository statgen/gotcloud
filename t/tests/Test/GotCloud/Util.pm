package Test::GotCloud::Util;

use base qw(Test::GotCloud);

use Modern::Perl;
use Test::Most;

use GotCloud::Util qw(:all);

sub class {
  return 'GotCloud::Util';
}

sub test_percentage : Test(no_plan) {
  is(percentage(0, 0),      0,        '0 total 0 reported');
  is(percentage(0, 10),     0,        '0 total 10 reported');
  is(percentage(undef, 10), 0,        'undef total 10 reported');
  is(percentage(10, -1),    '-10.00', '-1 total 10 reported');
  is(percentage(10, 1),     '10.00',  'got expected 10%');
}

1;
