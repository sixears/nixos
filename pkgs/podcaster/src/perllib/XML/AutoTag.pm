package XML::AutoTag;

=head1 NAME

XML::AutoTag - provide attributes that automatically write XML tags on sub entry/exit

=head1 DESCRIPTION

Assumes use of XML::Writer, and a hash-based class with an 'xmlwriter' hash
member being the XML::Writer instance to write to.

=cut

use strict;
use warnings;
no warnings qw( experimental::smartmatch );
use feature  qw( :5.10 );

use Attribute::Handlers  qw( );
use AutoDestroy;
use Data::Dumper         qw( );
use Scalar::Util         qw( reftype );

# ----------------------------------------------------------------------------

sub TAG : ATTR(CODE) {
  my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum)
    = @_;

  my $caller = join('::', $package, *$symbol{NAME});

  my ($tag_name, @tag_attrs);
  
  given (reftype $data) {
    when ( ! defined ) {
      if ( $data =~ /^(?<name>\w+)\(\s*(?<attrs>[\w\s.,=>]*?)\s*\)$/ ) {
        my $tag_attrs;
        ($tag_name, $tag_attrs) = @+{qw( name attrs )};
        @tag_attrs = split /\s*(?:,|=>)\s*/, $tag_attrs;
      } else {
        die sprintf "%s cannot handle scalar argument >>$data<<", __PACKAGE__
      }
    }

    when ( 'ARRAY' )
      { die sprintf "%s: too many parameters\n%s",
                   __PACKAGE__,
                   Data::Dumper->new([ $data ], [qw( data )])->Dump
          if 1 < @$data;
         die sprintf "%s: no parameters found\n%s", __PACKAGE__,
          if 0 == @$data;
        ($tag_name) = @$data;
      }
    default
      { die sprintf "%s: cannot parse data\n%s",
                   __PACKAGE__,
                   Data::Dumper->new([ $data ], [qw( data )])->Dump;
      }
  }

  no warnings 'redefine';
  *$symbol = sub {
    my ($self) = @_; # form closure for the auto_destroy
    $self->{xmlwriter}->startTag($tag_name, @tag_attrs);
    my $x = auto_destroy { $self->{xmlwriter}->endTag($tag_name) };
    # cannot goto here, as the pad is lost and so $x is destroyed.
    # but auto_destroy mean that in the event of $referent die()ing, we still
    # invoke the destroy - which may be valuable if the die is caught
    # goto &$referent;
    &$referent;
  };
}


# ----------------------------------------------------------------------------

1; # keep require happy
