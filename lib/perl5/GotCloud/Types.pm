## no critic (ProhibitPackageVars, Capitalization)
package GotCloud::Types;

use Exporter;
use base qw(Exporter);

use Type::Tiny;
use Modern::Perl;

our @EXPORT_OK = qw($FileOnDisk $Int $String $ArrayRef);
our %EXPORT_TAGS = (all => [qw($FileOnDisk $Int $String $ArrayRef)]);

our $FileOnDisk = Type::Tiny->new(
  name       => 'FileOnDisk',
  constraint => sub {-e $_ and -r $_ and not -z $_},
  message    => sub {"$_ is either not a file on disk, not readable, or zero length"},
);

our $Int = Type::Tiny->new(
  name       => 'Int',
  constraint => sub {/\d+/},
  message    => sub {"$_ is not an integer"},
);

our $String = Type::Tiny->new(
  name       => 'String',
  constraint => sub {/\w+/},
  message    => sub {"$_ is not a string"},
);

our $ArrayRef = Type::Tiny->new(
  name       => 'ArrayRef',
  constraint => sub {ref $_ eq 'ARRAY'},
  message    => sub {"$_ is not an array reference"},
);

1;
