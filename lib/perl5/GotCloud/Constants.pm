package GotCloud::Constants;

use base qw(Exporter);
use Modern::Perl;
use Readonly;

our @EXPORT_OK = (
  qw(
    $TRUE
    $FALSE
    $SPACE
    $EMPTY
    $NEWLINE
    $DUMMY
    $UMAKE_SUFFIX_SUCCESS
    $UMAKE_SUFFIX_ERROR
    $UMAKE_DEFAULT_TARGET
    $UMAKE_MAKEFILE_TARGET_REGEXP
    $UMAKE_MAKEFILE_NOT_TARGET_REGEXP
    $UMAKE_MAKEFILE_VAR_REGEXP
    $UMAKE_MAKEFILE_VAR_SUB_REGEXP
    $UMAKE_MAKEFILE_DELETE_TARGET_REGEXP
    %UMAKE_TARGET_REGEXP_MAP
    @UMAKE_STEP_ORDER
    $CHR_REGEXP
    )
);

our %EXPORT_TAGS = (
  all => [
    qw(
      $TRUE
      $FALSE
      $SPACE
      $EMPTY
      $NEWLINE
      $DUMMY
      $UMAKE_SUFFIX_SUCCESS
      $UMAKE_SUFFIX_ERROR
      $UMAKE_DEFAULT_TARGET
      $UMAKE_MAKEFILE_TARGET_REGEXP
      $UMAKE_MAKEFILE_NOT_TARGET_REGEXP
      $UMAKE_MAKEFILE_VAR_REGEXP
      $UMAKE_MAKEFILE_VAR_SUB_REGEXP
      $UMAKE_MAKEFILE_DELETE_TARGET_REGEXP
      %UMAKE_TARGET_REGEXP_MAP
      @UMAKE_STEP_ORDER
      $CHR_REGEXP
      )
  ],
  umake => [
    qw(
      $UMAKE_SUFFIX_SUCCESS
      $UMAKE_SUFFIX_ERROR
      $UMAKE_DEFAULT_TARGET
      $UMAKE_MAKEFILE_TARGET_REGEXP
      $UMAKE_MAKEFILE_NOT_TARGET_REGEXP
      $UMAKE_MAKEFILE_VAR_REGEXP
      $UMAKE_MAKEFILE_VAR_SUB_REGEXP
      $UMAKE_MAKEFILE_DELETE_TARGET_REGEXP
      %UMAKE_TARGET_REGEXP_MAP
      @UMAKE_STEP_ORDER
      $CHR_REGEXP
      )
  ],
);

Readonly::Scalar our $TRUE    => q{1};
Readonly::Scalar our $FALSE   => q{0};
Readonly::Scalar our $SPACE   => q{ };
Readonly::Scalar our $EMPTY   => q{};
Readonly::Scalar our $NEWLINE => qq{\n};
Readonly::Scalar our $DUMMY   => q{DUMMY};

Readonly::Scalar our $UMAKE_SUFFIX_SUCCESS                => q{.OK};
Readonly::Scalar our $UMAKE_SUFFIX_ERROR                  => q{.err};
Readonly::Scalar our $UMAKE_DEFAULT_TARGET                => q{all};
Readonly::Scalar our $UMAKE_MAKEFILE_TARGET_REGEXP        => qr{^([\w\W]+):(?:\s+([\w\W\s]+))?$};
Readonly::Scalar our $UMAKE_MAKEFILE_NOT_TARGET_REGEXP    => qr{^(?:\t|\s|\.)+};
Readonly::Scalar our $UMAKE_MAKEFILE_VAR_REGEXP           => qr{^([A-Z_]+)\=([\w\W]+)$};
Readonly::Scalar our $UMAKE_MAKEFILE_VAR_SUB_REGEXP       => qr{(\$\(([A-Z_]+)\))};
Readonly::Scalar our $UMAKE_MAKEFILE_DELETE_TARGET_REGEXP => qr{^\.DELETE_ON_ERROR:$};

Readonly::Array our @UMAKE_STEP_ORDER => (qw(glf glf_multiple sites pvcf stats vcf filter svm split));

Readonly::Scalar our $CHR_REGEXP   => q{(?<chr>(?:\d{1,2})|(?:X|Y))};
Readonly::Scalar my $START_REGEXP  => q{(?<start>\d+)};
Readonly::Scalar my $END_REGEXP    => q{(?<end>\d+)};
Readonly::Scalar my $SAMPLE_REGEXP => q{(?<sample>[\w.%-]+)};
Readonly::Scalar my $BAM_REGEXP    => q{(?<bam>[\w.%-]+)};

## no tidy
Readonly::Hash our %UMAKE_TARGET_REGEXP_MAP => (
  split => [
    qr{split/chr$CHR_REGEXP/chr\g{chr}\.filtered\.PASS\.split\.vcflist$},
    qr{split/chr$CHR_REGEXP/subset\.OK$},
  ],
  svm => [
    qr{vcfs/chr$CHR_REGEXP/chr\g{chr}\.filtered\.vcf\.gz.OK$},
    qr{\Qvcfs/filtered.vcf.gz.OK\E$},
  ],
  sites => [
    qr{vcfs/chr$CHR_REGEXP/$START_REGEXP\.$END_REGEXP/chr\g{chr}\.\g{start}\.\g{end}\.sites\.vcf\.OK$},
  ],
  pvcf => [
    qr{pvcfs/chr$CHR_REGEXP/$START_REGEXP\.$END_REGEXP/$BAM_REGEXP\.\g{chr}\.\g{start}\.\g{end}\.vcf\.gz\.OK$},
    qr{pvcfs/chr$CHR_REGEXP/$BAM_REGEXP\.\g{chr}\.vcf\.gz\.OK$},
  ],
  stats => [
    qr{vcfs/chr$CHR_REGEXP/$START_REGEXP\.$END_REGEXP/chr\g{chr}\.\g{start}\.\g{end}\.stats\.vcf\.OK$},
  ],
  filter => [
    qr{vcfs/chr$CHR_REGEXP/chr\g{chr}\.hardfiltered\.vcf\.gz\.OK$},
  ],
  vcf => [
    qr{vcfs/chr$CHR_REGEXP/chr\g{chr}\.merged\.vcf\.OK$},
  ],
  glf_multiple => [
    qr{vcfs/chr$CHR_REGEXP/$START_REGEXP\.$END_REGEXP/chr\g{chr}\.\g{start}\.\g{end}\.vcf\.OK$},
  ],
  glf => [
    qr{glfs/bams/$SAMPLE_REGEXP/chr$CHR_REGEXP/$BAM_REGEXP\.$START_REGEXP\.$END_REGEXP\.glf\.OK$},
    qr{glfs/samples/chr$CHR_REGEXP/$START_REGEXP\.$END_REGEXP/$SAMPLE_REGEXP\.\g{chr}\.\g{start}\.\g{end}\.glf\.OK$},
  ],
  default => [
    qr{^all$CHR_REGEXP?$},
    qr{^split$CHR_REGEXP$},
    qr{^svm$CHR_REGEXP$},
    qr{^pvcf$CHR_REGEXP$},
    qr{^filt$CHR_REGEXP$},
    qr{^vcf$CHR_REGEXP$},
    qr{^glf$CHR_REGEXP$},
  ],
);
## use tidy

1;
