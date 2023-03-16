package Tie::Hash::Fixed;

# pragmata

use strict;
use warnings;

# inheritance

use base       qw( Tie::Hash::ENoKey );

# utility

use Carp                  qw( croak );

# ----------------------------------------------------------------------------

use constant NO_SUCH_KEY     => q"no such key '%s' in hash lookup";
use constant WILL_NOT_STORE  => 'refusing subsequent store into fixed hash';
use constant WILL_NOT_DELETE => 'refusing subsequent delete from fixed hash';
use constant WILL_NOT_CLEAR  => 'refusing clear of fixed hash';

sub TIEHASH { bless +{%{$_[1] // +{}}}, $_[0] }

sub FETCH {
  croak sprintf(NO_SUCH_KEY, $_[1]) unless exists $_[0]->{$_[1]};
  $_[0]->SUPER::FETCH($_[1]);
}

sub STORE  { croak WILL_NOT_STORE }
sub DELETE { croak WILL_NOT_DELETE }
sub CLEAR  { croak WILL_NOT_CLEAR }

# ----------------------------------------------------------------------------

if ( caller ) {
  1; # keep require happy
} else {
  # test harness

  # don't pay the load cost for day-to-day usage
  require Test::More;
  Test::More->import(tests => 12);
#  Test::More->import('diag');

  tie my %xx, 'Tie::Hash::Fixed', +{ c => 4, d => 5 };
  is($xx{c}, 4,                                                  '$x{c} is 4');

  ok( ! $@,                                                           'not $@')
    or diag ($@);
  eval { %xx = (a => 3, b => 2) };
  is(substr($@, 0, length WILL_NOT_CLEAR), WILL_NOT_CLEAR,       'init failed');

  $@ = '';
  eval { @xx{qw( a b )} = (3, 2) };
  is(substr($@, 0, length WILL_NOT_STORE), WILL_NOT_STORE,      'store failed');

  $@ = '';
  eval { delete $xx{a} };
  is(substr($@, 0, length WILL_NOT_DELETE), WILL_NOT_DELETE,   'delete failed');

  $@ = '';
  eval { %xx = () };
  is(substr($@, 0, length WILL_NOT_CLEAR), WILL_NOT_CLEAR,      'clear failed');

  tie my %hash, 'Tie::Hash::Fixed';
  $@ = '';
  ok( ! $@,                                                           'not $@')
    or diag ($@);
  eval { $hash{present} = 3 };
  is(substr($@, 0, length WILL_NOT_STORE), WILL_NOT_STORE,     'assign failed');

  my $present = eval { $hash{present} };
  my $errmsg = sprintf(NO_SUCH_KEY, 'present');
  is(substr($@, 0, length $errmsg), $errmsg,           'hash:present (throws)');
  ok(! defined $present,                             'hash:present (no value)');

  my $absent = eval { $hash{absent} };
  $errmsg = sprintf(NO_SUCH_KEY, 'absent');
  is(substr($@, 0, length $errmsg), $errmsg,            'hash:absent (throws)');
  ok(! defined $absent,                               'hash:absent (no value)');
}
