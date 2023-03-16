package AutoDestroy;

use strict;
use warnings;

use base qw( ParamCheck Exporter );
our @EXPORT    = qw( auto_destroy );
our @EXPORT_OK = qw( auto_destroy );

sub new : CheckP(_,CR) { my $x = $_[1]; bless \$x, $_[0] }

sub DESTROY { &{${$_[0]}} }

sub auto_destroy(&) { __PACKAGE__->new($_[0]) }

1; # keep require happy
