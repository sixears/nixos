package Lazy;

use strict;
use warnings;
use feature  qw( :5.10 );

use base qw( Exporter );
our @EXPORT    = qw( lazy );
our @EXPORT_OK = qw( lazy );

use Carp          qw( croak );
use Memoize       qw( memoize );
use Scalar::Util  qw( refaddr );

use overload '""' => 'evaluate';

sub new {
  # no CheckP : ParamCheck uses Lazy, so we avoid circularity
  my ($class,$subr) = @_;
  croak "must be a subref: $subr\n"
    if ! UNIVERSAL::isa($subr,'CODE');
  my $x = $subr;
  bless \$x, $class;
}

sub evaluate { ${$_[0]}->() }
memoize('evaluate', NORMALIZER => sub { refaddr $_[0] } );

sub lazy(&) { __PACKAGE__->new($_[0]) }

# ----------------------------------------------------------------------------

if ( caller ) { # normal library usage
  1;
} else { # test!
  require Test::More;
  Test::More->import(tests => 8);

  my $e = 0;
  my $x = Lazy->new(sub { $e++; 1 + 2 + 3 + 4 + 5 });
  is($e, 0,                                                            'not e');
  is($x->evaluate, 15,                                              'evaluate');
  is($e, 1,                                                                'e');
  is($x->evaluate, 15,                                           're-evaluate');
  is($e, 1,                                                          'e again');

  $e = 0;
  my $y = lazy { $e++; sprintf '%s is %s', 'The truth', 'out there' };
  is($e, 0,                                                            'not e');
  is($y, 'The truth is out there',                                      'lazy');
  is($e, 1,                                                           'more e');
}
