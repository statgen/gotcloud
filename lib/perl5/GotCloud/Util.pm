package GotCloud::Util;

use Exporter;
use base qw(Exporter);

use Modern::Perl;
use GotCloud::Constants qw(:all);

our @EXPORT_OK = (
  qw(
    percentage
    )
);
our %EXPORT_TAGS = (all => [qw(percentage)]);

sub percentage {
  my ($total, $reported) = @_;
  return $FALSE if not $total or $total == 0 or ($total == 0 and $reported == 0);
  return sprintf '%.2f', (($reported / $total) * 100);
}

1;
