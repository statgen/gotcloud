package GotCloud::Status::Command::umake;

use GotCloud::Status -command;
use Modern::Perl;
use Parallel::ForkManager;
use List::MoreUtils qw(uniq part);

use GotCloud::Util qw(:all);
use GotCloud::Constants qw(:all);
use GotCloud::Umake::Makefile::Parser;

sub opt_spec {
  return (
    ['makefile|m=s',   'Umake generated makefile location'],
    ['step|s=s@',      'pipeline steps to test'],
    ['detail|d',       'Give more detailed output'],
    ['concurrent|c=i', 'How many concurrent chromosomes to process (defaults: to all)'],
  );
}

sub validate_args {
  my ($self, $opt, $args) = @_;

  if (not exists $opt->{makefile} or not -e $opt->makefile or not -r $opt->makefile) {
    $self->usage_error('makefile is required');
  } else {
    $self->{stash}->{parser} = GotCloud::Umake::Makefile::Parser->new(makefile => $opt->makefile);
    push @{$self->{stash}{steps}}, defined $opt->step ? @{$opt->step} : reverse @{$self->{stash}->{parser}->steps};
  }

  my $max_procs = $self->{stash}->{parser}->total_chromosomes;

  if ($opt->concurrent and ($opt->concurrent < $max_procs)) {
    $max_procs = $opt->concurrent;
  }

  $self->{stash}->{max_procs} = $max_procs;
}

sub execute {
  my ($self, $opt, $args) = @_;

  my $max_procs   = $self->{stash}->{max_procs};
  my $parser      = $self->{stash}->{parser};
  my @steps       = @{$self->{stash}->{steps}};
  my @chromosomes = @{$parser->chromosomes};
  my $pm          = Parallel::ForkManager->new($max_procs);
  my $i           = 0;
  my $chunk_size  = int($parser->total_chromosomes / $max_procs);
  my @chunks      = part {int($i++ / $chunk_size)} @chromosomes;    #/ fixes vim syntax highlighting

  $pm->run_on_finish(
    sub {
      my ($pid, $code, $ident, $signal, $core, $ref) = @_;
      push @{$self->{stash}->{failures}}, @{$ref} if $ref;
      return;
    }
  );

  for my $chunk (@chunks) {
    $pm->start and next;

    for my $chr (@{$chunk}) {
      my @child_failures = ();

      for my $step (@steps) {
        my @targets = @{$parser->get_targets_for_step($step, $chr)};

        for my $target (@targets) {
          next if $target->is_default_target;
          push @child_failures, $target unless $target->is_success;
        }
      }

      $pm->finish(0, \@child_failures);
    }
  }

  $pm->wait_all_children;
  $self->process_results($opt, $args);
  $self->output($opt, $args);

  return;
}

sub process_results {
  my ($self, $opt, $args) = @_;

  my $parser      = $self->{stash}->{parser};
  my $fail_ref    = $self->{stash}->{failures};
  my $total_steps = $parser->total_steps;
  my $params      = {detail => $opt->detail || 0};

  for my $chr (@{$parser->chromosomes}) {
    my $error_steps = uniq map {$_->step} grep {$_->chromosome eq $chr} @{$fail_ref};
    my $completed_steps = $total_steps - $error_steps;

    my $result_ref = {
      id                   => $chr,
      completed_steps      => $completed_steps,
      total_steps          => $total_steps,
      completed_percentage => percentage($total_steps, $completed_steps),
      steps                => [],
    };

    for my $step (reverse @{$parser->steps}) {
      my $targets           = $parser->get_targets_for_step($step, $chr);
      my $total_targets     = scalar @{$targets};
      my @error_targets     = grep {$_->chromosome eq $chr and $_->step eq $step} @{$fail_ref};
      my $completed_targets = $total_targets - scalar @error_targets;

      unless ($opt->detail) {
        next if $total_targets <= 0;
      }

      push @{$result_ref->{steps}}, {
        name                 => $step,
        total_targets        => $total_targets,
        completed_targets    => $completed_targets,
        completed_percentage => percentage($total_targets, $completed_targets),
        error_targets        => [map +{target => $_->name}, @error_targets],
        };
    }

    if (scalar @{$result_ref->{steps}}) {
      push @{$params->{chromosomes}}, $result_ref;
    }
  }

  $self->{stash}->{params} = $params;

  return;
}

sub output {
  my ($self, $opt, $args) = @_;
  my $params = $self->{stash}->{params};

  for my $chr (@{$params->{chromosomes}}) {
    say "\nChromosome $chr->{id}: $chr->{completed_steps} of $chr->{total_steps} ($chr->{completed_percentage}%)";

    for my $step (@{$chr->{steps}}) {
      say "\t$step->{name}: $step->{completed_targets} of $step->{total_targets} ($step->{completed_percentage}%)";

      if ($opt->detail) {
        say "\tFailed Targets:";

        for my $err (@{$step->{error_targets}}) {
          say "\t\t$err->{target}";
        }
      }
    }
  }
}

1;

__END__

=head1 NAME

GotCloud::Status::Command::umake - Show the status of all targets, chromosomes, and steps for a given umake generated makefile.

=cut
