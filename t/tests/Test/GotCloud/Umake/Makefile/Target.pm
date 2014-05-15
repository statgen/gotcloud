package Test::GotCloud::Umake::Makefile::Target;

use base qw(Test::GotCloud);

use Modern::Perl;
use Test::Most;
use Test::Exception;
use List::MoreUtils qw(first_index);

use GotCloud::Umake::Makefile::Target;

sub _find_target {
  my ($self, $name) = @_;
  my $targets = $self->{fixture}->{targets};
  return $targets->[first_index {$_->name eq $name} @{$targets}];
}

sub class {
  'GotCloud::Umake::Makefile::Target';
}

sub startup : Test(startup) {
  my ($self) = @_;
  $self->{fixture}->{targets} = do $self->{fixture_path} . '/targets.pl';

## no tidy
  $self->{test_targets} = {
    'all20' => {
      step    => 'default',
      depends => [qw(split20 svm20 filt20 pvcf20 vcf20 glf20)],
      chromosome => 20,
    },
    'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK' => {
      step         => 'sites',
      chromosome   => 20,
      region_start => 20000001,
      region_end   => 25000000,
      depends      => [qw(vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK)],
    },
    'pvcfs/chr20/20000001.25000000/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK' => {
      step         => 'pvcf',
      chromosome   => 20,
      region_start => 20000001,
      region_end   => 25000000,
      bam          => 'NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
      depends      => [qw(vcfs/chr20/20000001.25000000/chr20.20000001.25000000.sites.vcf.OK)],
    },
    'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.stats.vcf.OK' => {
      step         => 'stats',
      chromosome   => 20,
      region_start => 20000001,
      region_end   => 25000000,
      'depends'    => [
        'pvcfs/chr20/20000001.25000000/NA12272.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12004.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12749.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA10847.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12716.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12275.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12750.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12348.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12347.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12003.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12286.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11829.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA07357.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12144.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12045.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12045.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12812.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12718.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12777.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12872.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12751.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12717.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA07051.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12249.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12249.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11992.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12058.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12889.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12400.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12778.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12154.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11932.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11931.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11931.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA06986.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA07056.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12046.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12342.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA06984.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12273.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12748.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12814.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12546.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12827.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12489.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12283.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11919.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11995.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA07000.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA10851.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11918.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12341.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11892.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12383.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA06994.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12006.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12043.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12043.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11993.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12413.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA11920.mapped.ILLUMINA.bwa.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'pvcfs/chr20/20000001.25000000/NA12874.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20.20000001.25000000.vcf.gz.OK',
        'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK'
      ],
    },
    'vcfs/chr20/chr20.hardfiltered.vcf.gz.OK' => {
      step       => 'filter',
      chromosome => 20,
      depends    => [
        'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.stats.vcf.OK',
        'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK',
        'vcfs/chr20/chr20.merged.vcf.OK'
      ],
    },
    'vcfs/chr20/chr20.merged.vcf.OK' => {
      step       => 'vcf',
      chromosome => 20,
      depends    => [qw(vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK)],
    },
    'vcfs/chr20/20000001.25000000/chr20.20000001.25000000.vcf.OK' => {
      step         => 'glf_multiple',
      chromosome   => 20,
      region_start => 20000001,
      region_end   => 25000000,
      depends      => [
        'glfs/samples/chr20/20000001.25000000/NA12272.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12004.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11994.20.20000001.25000000.glf.OK', 
        'glfs/samples/chr20/20000001.25000000/NA12749.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA10847.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12716.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12829.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12275.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12750.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12348.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12347.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12003.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12286.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11829.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA07357.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12144.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12045.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12812.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12718.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12777.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12872.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12751.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12717.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA07051.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12249.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11992.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12058.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12889.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12400.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12778.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12154.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11932.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11931.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA06986.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA07056.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12046.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12342.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA06984.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12273.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12748.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12814.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12546.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12827.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12489.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12283.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11919.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11995.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA07000.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA10851.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11918.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12341.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11892.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12383.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA06994.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12006.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12043.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11993.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12413.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA11920.20.20000001.25000000.glf.OK',
        'glfs/samples/chr20/20000001.25000000/NA12874.20.20000001.25000000.glf.OK'
      ],
    },
    'glfs/bams/NA11918/chr20/NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam.20000001.25000000.glf.OK' => {
      step         => 'glf',
      chromosome   => 20,
      region_start => 20000001,
      region_end   => 25000000,
      sample       => 'NA11918',
      depends      => [],
      bam          => 'NA11918.mapped.LS454.ssaha2.CEU.low_coverage.20101123.chrom20.20000001.20300000.bam',
    },
  };
## use tidy
}

sub test_targets : Test(no_plan) {
  my ($self) = @_;
  my $class  = $self->class;

  dies_ok(sub {$class->new(name => 'foo')}, 'expecting instantiation to die with bad name');
  dies_ok(sub {$class->new(name => 'all', depends => 'foo')}, 'expecting instantiation to die with bad depends');

  for my $name (keys %{$self->{test_targets}}) {
    my $fixture = $self->_find_target($name);
    my $target  = $self->class->new(
      name    => $name,
      depends => $self->{test_targets}->{$name}->{depends}
    );

    ok(defined $fixture, 'found a matching target name');
    isa_ok($target, $self->class);

    can_ok($target, 'name');
    is($target->name, $fixture->name, 'names match');

    can_ok($target, 'has_depends');
    is($target->has_depends, $fixture->has_depends, 'depends predicate works');

    can_ok($target, 'depends');
    is_deeply($target->depends, $fixture->depends, 'dependency list matches');

    can_ok($target, 'err_file');
    is($target->err_file, $fixture->err_file, 'error file matches');

    can_ok($target, 'ok_file');
    is($target->ok_file, $fixture->ok_file, 'ok file matches');

    can_ok($target, 'step');
    is($target->step, $fixture->step, 'step matches');

    can_ok($target, 'has_chromosome');
    is($target->has_chromosome, $fixture->has_chromosome, 'chromosome predicate works');

    can_ok($target, 'chromosome');
    is($target->chromosome, $fixture->chromosome, 'chromosome matches');

    can_ok($target, 'has_region_start');
    is($target->has_region_start, $fixture->has_region_start, 'region_start predicate works');

    can_ok($target, 'region_start');
    is($target->region_start, $fixture->region_start, 'region_start matches');

    can_ok($target, 'has_region_end');
    is($target->has_region_end, $fixture->has_region_end, 'region_end predicate works');

    can_ok($target, 'region_end');
    is($target->region_end, $fixture->region_end, 'region_end matches');

    can_ok($target, 'region');
    is($target->region, $fixture->region, 'region matches');

    can_ok($target, 'has_sample');
    is($target->has_sample, $fixture->has_sample, 'sample predicate works');

    can_ok($target, 'sample');
    is($target->sample, $fixture->sample, 'sample matches');

    can_ok($target, 'has_bam');
    is($target->has_bam, $fixture->has_bam, 'bam predicate works');

    can_ok($target, 'bam');
    is($target->bam, $fixture->bam, 'bam matches');

    can_ok($target, 'is_default_target');
    can_ok($target, 'is_success');
  }
}

1;
