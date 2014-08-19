package GotCloud::Umake::Makefile::Target;

use Moo;
use namespace::clean;
use Modern::Perl;
use File::Basename;
use Carp qw(confess);

use GotCloud::Constants qw(:all);
use GotCloud::Types qw(:all);

has 'name'         => (is => 'ro', isa => $String, required => 1, trigger => 1);
has 'depends'      => (is => 'ro', isa => $ArrayRef, predicate => 1);
has 'chromosome'   => (is => 'rwp', predicate => 1, default => sub {'DUMMY'});
has 'region_start' => (is => 'rwp', predicate => 1);
has 'region_end'   => (is => 'rwp', predicate => 1);
has 'sample'       => (is => 'rwp', predicate => 1);
has 'bam'          => (is => 'rwp', predicate => 1);
has 'step'         => (is => 'rwp');
has 'region'       => (is => 'lazy');
has 'err_file'     => (is => 'lazy');
has 'ok_file'      => (is => 'lazy');

sub _trigger_name {
  my ($self) = @_;

  for my $step (keys %UMAKE_TARGET_REGEXP_MAP) {
    for my $regexp (@{$UMAKE_TARGET_REGEXP_MAP{$step}}) {

      if ($self->name =~ /$regexp/) {
        $self->_set_step($step);

        ## no critic (ProhibitPunctuationVars, ProhibitPostfixControls)
        $self->_set_chromosome($+{chr})     if exists $+{chr};
        $self->_set_region_start($+{start}) if exists $+{start};
        $self->_set_region_end($+{end})     if exists $+{end};
        $self->_set_sample($+{sample})      if exists $+{sample};
        $self->_set_bam($+{bam})            if exists $+{bam};

        return;
      }
    }
  }

  confess 'Unable to determine target type from name: ' . $self->name;
}

sub _build_err_file {
  my ($self) = @_;
  my ($file, $path, $suffix) = fileparse($self->name, $UMAKE_SUFFIX_SUCCESS);
  return $path . $file . $UMAKE_SUFFIX_ERROR;
}

sub _build_ok_file {
  return shift->name;
}

sub _build_region {
  my ($self) = @_;
  return if not defined $self->region_start or not defined $self->region_end;
  return sprintf '%d.%d', $self->region_start, $self->region_end;
}

sub is_default_target {
  return shift->step eq 'default';
}

sub is_success {
  return -e shift->ok_file;
}

1;

__END__

=head1 NAME

GotCloud::Umake::Makefile::Target

=head1 VERSION

See I<release_version.txt>.

=head1 SYNOPSIS

  my $target = GotCloud::Umake::Makefile::Target->new(name => '/some/target/path');

  # test if the target was successfully ran
  if ($target->is_success) {
    print "woot!\n";
  }

  # what chromosome is this target working on
  my $chr = $target->chromosome;

=head1 DESCRIPTION

This module will create an object respresenting a umake makefile target based
on the target name, ie; the path of the B<.OK> file. This allows you to test
wether or not the target has completed successfully.

=head1 SUBROUTINES/METHODS

=over 5

=item C<$target = GotCloud::Umake::Makefile::Target-E<gt>new(name =E<gt> '/some/target')>

Constructs a new target object by parsing the given name accordding to the
regular expression map in C<GotCloud::Constants::UMAKE_TARGET_REGEXP_MAP>. If
a match is found the object is created with all fields popuplated, if no match
is found an exception is thrown with stack trace.

=item C<$target-E<gt>depends()>

Get/Set an arrayref of dependencies to this target.

=item C<$target-E<gt>chromosome()>

Get the chromosome for this target.

=item C<$target-E<gt>region_start()>

Get the region start, if defined, for this target.

=item C<$target-E<gt>region_end()>

Get the region end, if defined, for this target.

=item C<$target-E<gt>sample()>

Get the sample name, if defined, for this target.

=item C<$target-E<gt>bam()>

Get the bam name, if defined, for this target.

=item C<$target-E<gt>step()>

Get the step that this target belongs to, ie; glf, vcf.

=item C<$target-E<gt>region()>

Get the region, if defined, of the target.

=item C<$target-E<gt>err_file()>

Get the I<.err> file path for the target.

=item C<$target-E<gt>ok_file()>

Get the I<.OK> file path for the target.

=item C<$target-E<gt>is_default_target()>

Test is the target is a default target such as I<all#>.

=item C<$target-E<gt>is_success()>

Test wether the target has completed successfully or not.

=back

=head1 DIAGNOSTICS

None at this time.

=head1 CONFIGURATION AND ENVIRONMENT

No configuration is necessary. This module will only work within the L<GotCloud|GotCloud>
appliacation.

=head1 DEPENDENCIES

=over 5

=item L<Moo|Moo>

=item L<Modern::Perl|Modern::Perl>

=back

=head1 INCOMPATIBILITIES

None known at this time.

=head1 BUGS AND LIMITATIONS

This will only generate an object from a umake generated makefile target.

=head1 AUTHOR

Written by Chris Scheller I<E<lt>schelcj@umich.eduE<gt>>.

=head1 LICENSE AND COPYRIGHT

This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; See L<http://www.gnu.org/copyleft/gpl.html>

=cut
