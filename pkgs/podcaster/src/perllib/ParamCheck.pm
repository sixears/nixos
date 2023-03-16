package ParamCheck;

=head1 ParamCheck

check function invocation parameters, using attributes

=cut

use strict;
use warnings;
no warnings qw( experimental::smartmatch );
use feature  qw( :5.10 );

use Attribute::Handlers  qw( );
use Lazy                 qw( lazy );
use Params::Validate     qw( validate_with
                             SCALAR ARRAYREF HASHREF CODEREF UNDEF );

# ----------------------------------------------------------------------------

sub CheckP : ATTR(CODE) {
  my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum)
    = @_;

  my $caller = join('::', $package, *$symbol{NAME});

  # Attribute::Handlers can't always parse the args into an array
  # this happens if, say, args contains a '?'
  my @fields = UNIVERSAL::isa($data, 'ARRAY') ? @$data : split /,/, $data;

  my $dstring = lazy { ref $data ? join ',', @$data : $data };

=pod

  die sprintf "parse error on multiple ';' in spec '%s' at %s (%s:%d); '%s'\n",
              $dstring, $caller, $filename, $linenum, $_
    if grep 1 < tr/;/;/, @fields;
  my @semis = grep -1 < index($fields[$_],';'), 0..$#fields;
  die sprintf "too many semi-colons in spec '%s' at %s (%s:%d); '%s'\n",
              $dstring, $caller, $filename, $linenum, $_
    if 1 < @semis;

=cut

  my $optional;
  my @spec;
  local $_;
  for $_ (@fields) {
    when ( '_' )   { push @spec, +{ isa  => $package }                  }
    when ( 'S' )   { push @spec, +{ type => SCALAR }                    }
    when ( 'S?' )  { push @spec, +{ type => SCALAR | UNDEF }            }
    when ( 'AR' )  { push @spec, +{ type => ARRAYREF }                  }
    when ( 'AR?' ) { push @spec, +{ type => ARRAYREF | UNDEF }          }
    when ( 'HR' )  { push @spec, +{ type => HASHREF }                   }
    when ( 'HR?' ) { push @spec, +{ type => HASHREF | UNDEF }           }
    when ( 'CR' )  { push @spec, +{ type => CODEREF }                   }
    when ( /::/ )  { (my $p = $_) =~ /^::/; push @spec, +{ isa  => $_ } }
    when ( ';' )   {
      die sprintf "too many ';' in spec '%s' at %s (%s:%d); '%s'\n",
                  $dstring, $caller, $filename, $linenum, $_
        if $optional;
      $optional = 1;
    }
    default        {
      (my $thismethod = (caller 0)[3]) =~ s/^.*:://;
      die sprintf "unrecognized %s spec at %s (%s:%d); '%s'\n",
                  $thismethod, $caller, $filename, $linenum, $_;
    }
  } continue {
    $spec[-1]->{optional} = 1
      if $optional;
  }

  if ( $ENV{__DUMP_PARAM_CHECK} ) {
    require Data::Dumper;
    printf STDERR "%s:%d:\n%s\n", $filename, $linenum, Data::Dumper->new([\@spec],[qw( spec )])->Indent(0)->Dump;
  }

  no warnings 'redefine';
  *$symbol = sub {
    validate_with(params => \@_, spec => \@spec, called => $caller,
                  on_fail => sub {
                    die @_, sprintf " at %s:%d (%s)\n",
                                    (caller 1)[1,2], (caller 2)[3]
                  }
                 );
    goto &$referent;
  };
}


# ----------------------------------------------------------------------------

1; # keep require happy
