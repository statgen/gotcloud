package Test::GotCloud;

use base q(Test::Class);
use FindBin qw($Bin);
use Test::Most;
use IPC::System::Simple qw(run);
use File::Temp qw(tempdir);

sub make_fixture : Test(startup => 2) {
  my ($self) = @_;

  $self->{fixture_path}     = qq{$Bin/../t/fixtures};
  $self->{tmpdir}           = $ENV{UMAKE_TMPDIR} // tempdir(CLEANUP => 0);
  $self->{snpcall_conf}     = qq($self->{tmpdir}/umake_test.snpcall.conf);
  $self->{snpcall_makefile} = qq($self->{tmpdir}/umake_test.snpcall.Makefile);

  $self->{aligner}      = qq($Bin/../bin/align.pl);
  $self->{aligner_conf} = qq($Bin/../test/align/test.conf);
  $self->{align_opts}   = qq(-conf $self->{aligner_conf} -index_file $Bin/../test/align/indexFile.txt -ref_dir $Bin/../test/chr20Ref/ -fastq_prefix $Bin/../test/align);
  $self->{align_cmd}    = qq($self->{aligner} $self->{align_opts} -out $self->{tmpdir});

  $self->{umake}      = qq($Bin/../bin/umake.pl);
  $self->{umake_conf} = qq($Bin/../test/umake/umake_test.conf);
  $self->{umake_opts} = qq(-conf $self->{umake_conf} -snpcall -out $self->{tmpdir} --numjobs 2);
  $self->{umake_cmd}  = qq($self->{umake} $self->{umake_opts});

  if (not $ENV{UMAKE_TMPDIR}) {
    diag(qq(Running aligner setup: $self->{align_cmd}));
    run(qq($self->{align_cmd}));

    diag(qq(Running umake: $self->{umake_cmd}));
    run($self->{umake_cmd});

    diag(qq(Test umake build is stored in $self->{tmpdir}));
  }

  ok(-e $self->{tmpdir},           'Successfully created temporary directory for test run');
  ok(-e $self->{snpcall_makefile}, 'Makefile created by umake');
}

sub cleanup : Test(shutdown) {
}

1;
