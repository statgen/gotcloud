package GotCloud::Status::Command::cache;

use GotCloud::Status -command;
use Modern::Perl;
use File::Path qw(remove_tree);
use Data::Dumper;

sub opt_spec {
  return (
    ['makefile|m=s',      'Umake generated makefile location'],
    ['init|i',            'Initialize cache'],
    ['dump|d',            'Dump cache to STDOUT'],
    ['flush|f',           'Flush the cache'],
    ['verbose|v',         'Verbose output'],
    ['dump_target_names', 'for debugging'],
  );
}

sub validate_args {
  my ($self, $opt, $args) = @_;

  if (not exists $opt->{makefile} or not -e $opt->makefile or not -r $opt->makefile) {
    $self->usage_error('makefile is required');
  }
}

sub execute {
  my ($self,$opt,$args) = @_;

  my $parser = GotCloud::Umake::Makefile::Parser->new(makefile => $opt->makefile);

  if ($opt->init) {
    $parser->targets;
    say 'Targets cached: ' . $parser->total_targets if $opt->verbose;

    $parser->default_targets;
    say 'Default targets cached: ' . scalar @{$parser->default_targets} if $opt->verbose;

    $parser->vars;
    say 'Vars cached: ' . scalar keys %{$parser->vars} if $opt->verbose;

    $parser->steps;
    say 'Steps cached: ' . scalar @{$parser->steps} if $opt->verbose;

    $parser->chromosomes;
    say 'Chromosomes cached: ' . $parser->total_chromosomes if $opt->verbose;
  }

  if ($opt->dump) {
    $Data::Dumper::Varname = 'STEPS';
    print Dumper $parser->steps;

    $Data::Dumper::Varname = 'CHROMOSOMES';
    print Dumper $parser->chromosomes;

    $Data::Dumper::Varname = 'VARS';
    print Dumper $parser->vars;

    $Data::Dumper::Varname = 'DEFAULT_TARGETS';
    print Dumper $parser->default_targets;

    $Data::Dumper::Varname = 'TARGETS';
    print Dumper $parser->targets;
  }


  if ($opt->flush) {
    remove_tree($parser->cache_root, {verbose => 1});
  }

  if ($opt->dump_target_names) {
    for my $target (@{$parser->targets}) {
      next if $target->is_default_target;
      say $target->name;
    }
  }
}

1;

__END__

=head1 NAME

GotCloud::Status::Command::cache - Caching functions for targets within a umake generated makefile.

=cut
