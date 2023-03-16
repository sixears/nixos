package Tie::Hash::ENoKey;

# pragmata

use strict;
use warnings;

# inheritance

use Tie::Hash  qw( );
use base       qw( Tie::StdHash );

# utility

use Carp  qw( croak );

# ----------------------------------------------------------------------------

use constant NO_SUCH_KEY => q"no such key '%s' in hash lookup";

sub FETCH {
  croak sprintf(NO_SUCH_KEY, $_[1]) unless exists $_[0]->{$_[1]};
  $_[0]->SUPER::FETCH($_[1]);
}

# ----------------------------------------------------------------------------

if ( caller ) {
  1; # keep require happy
} else {
  # test harness

  # don't pay the load cost for day-to-day usage
  require Test::More;
  Test::More->import(tests => 3);

  tie my %hash, 'Tie::Hash::ENoKey';
  $hash{present} = 3;
  is($hash{present}, 3,                                         'hash:present');
  my $absent = eval { $hash{absent} };
  my $errmsg = sprintf(NO_SUCH_KEY, 'absent');
  is(substr($@, 0, length $errmsg), $errmsg,            'hash:absent (throws)');
  ok(! defined $absent,                               'hash:absent (no value)');
}
