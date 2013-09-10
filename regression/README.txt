                             Notes on Regression Testing for GotCloud

This is the beginning of a regression test for GotCloud. It'll never be a complete
all-singing, all-dancing version, since the pipeline process is so complex.
Rather this part is to help us ensure some bits are correct.

SANITY TEST

A basic sanity test is provided for the aligner and SNP caller. To test the aligner, run:

  gotcloud align --test ~/testalign

This will create/clear the output directory ~/testalign where results and a log file are
to be found. Results are self-checked and if errors should occur, it will be obvious.

To test the GotCloud umake, run:

  gotcloud snpcall --test ~/testsnp

This will create/clear the output directory ~/testsnp where results and a log file are
to be found. Results are self-checked and if errors should occur, it will be obvious.

These tests will verify you have the basics installed and they appear to work.


REGRESSION TEST

The files in this directory will help verify some of the underlying tools behave
as expected. They are really provided for the developers, but anyone can run them.
This regression bucket uses a standard Perl module, ExtUtils::MakeMaker, which
is used by many modules for their regression testing.

You must have compiled the source before running this:

  (cd src; make)

Run the regression bucket with the commands:

  perl Makefile.PL
  make test
  make clean; rm -rf tmp Makefile.old


If you want to make changes to the regression bucket, the Perl code is in various
files named '*.t' under the 't' subdirectory. You can work on an individual
test case like this:

  cd t/dirname
  perl filename.t           # Some pgms accept special debugging parameters. Check the scource
    or even
  perl -d filename.t



A clean run looks something like this:
  make test
  PERL_DL_NONLAZY=1 /usr/bin/perl "-MExtUtils::Command::MM" "-e" "test_harness(0, ...
  t/align/01.t .. ok
  t/conf/01.t ... ok
    and maybe some more
  All tests successful.
  Files=2, Tests=31,  1 wallclock secs ( 0.05 usr  0.02 sys +  0.43 cusr  0.09 csys =  0.59 CPU)
  Result: PASS
