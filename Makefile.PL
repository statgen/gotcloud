use 5.010001;

use strict;
use warnings;

use ExtUtils::MakeMaker;

#   Perl people, don't expect too much from this.
#   This is just a small scaffold so we can possibly create something like a regression bucket

my $v = `cat release_version.txt`;
WriteMakefile(
  NAME         => 'GotCloud',
  VERSION      => $v,
  ABSTRACT     => 'Sequencing and Genotyping Pipelines on the Cloud',
  AUTHOR       => 'Mary Kate Wing <mktrost@umich.edu>',
  LICENSE      => 'GPL',
  META_MERGE   => {
    requires  => {perl => '5.010001'},
    resources => {
      homepage    => 'http://genome.sph.umich.edu/wiki/GotCloud:_Genetic_Reference_and_Resource_Files',
      license     => 'http://www.gnu.org/copyleft/gpl.html',
      repository  => 'http://github.com/kraih/mojo',
      bugtracker  => 'http://github.com/kraih/mojo/issues'
    },
    no_index => {directory => ['t']}
  },
  #EXE_FILES => ['script/hypnotoad', 'script/mojo', 'script/morbo'],
  test => {TESTS => 't/*.t t/*/*.t'}
);
