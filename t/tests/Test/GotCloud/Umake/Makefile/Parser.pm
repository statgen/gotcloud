package Test::GotCloud::Umake::Makefile::Parser;

use base q(Test::GotCloud);

use Modern::Perl;
use File::Spec;
use Test::Most;

use GotCloud::Umake::Makefile::Parser;

sub class {
  return 'GotCloud::Umake::Makefile::Parser';
}

sub setup : Test(setup) {
  my ($self) = @_;
  $self->{parser} = $self->class->new(makefile => $self->{snpcall_makefile});
}

sub test_targets : Test(no_plan) {
  my ($self) = @_;
  my $parser = $self->{parser};

  can_ok($parser, 'targets');

  my $targets = $parser->targets;

  is(ref $targets,       'ARRAY', 'targets is an arrayref');
  is(scalar @{$targets}, 151,     'correct number of targets returned');
}

sub test_targets_for_step : Test(2) {
  my ($self) = @_;
  my $step   = q{glf};
  my $chr    = 20;
  my $parser = $self->{parser};
  can_ok($parser, 'get_targets_for_step');
  my $targets = $parser->get_targets_for_step($step, $chr);
  is(scalar @{$targets}, 70, 'has correct number of targets for glf step');
}

sub test_default_targets : Test(9) {
  my ($self) = @_;

  my $parser   = $self->{parser};
  my @defaults = (qw(all all20 split20 svm20 filt20 pvcf20 vcf20 glf20));
  my @targets   = @{$parser->default_targets};

  is($parser->total_default_targets, scalar @defaults, 'count of default targets matches');

  for my $name (@defaults) {
    my $count = grep {$_->name eq $name} @targets;
    ok($count, 'found default target');
  }
}

sub test_chromosomes : Test(2) {
  my ($self) = @_;
  my $parser = $self->{parser};

  is_deeply($parser->chromosomes, [20, 'DUMMY'], 'correct chromosomes found');
  is($parser->total_chromosomes, '2', 'correct number of chromsomes found');
}

sub test_steps : Test(10) {
  my ($self) = @_;
  my $parser = $self->{parser};
  my @steps  = (qw(pvcf sites glf filter stats vcf glf_multiple svm split));

  is($parser->total_steps, scalar @steps, 'correct number of steps found');

  for my $step (@steps) {
    ok(grep {$step} @{$parser->steps}, 'step exists');
  }
}

sub test_vars : Test(3) {
  my ($self) = @_;
  my $parser = $self->{parser};

  can_ok($parser, 'vars');
  can_ok($parser, 'var');
  is($parser->var('OUT_DIR'), $self->{tmpdir}, 'temporary directory path matches OUT_DIR');
}


1;
