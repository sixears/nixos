package XML::Writer::Scopes;

=head1 NAME

XML::Writer::Scopes - xml methods for tags that close themselves when scopes end

=cut

use strict;
use warnings;

use XML::Writer  qw( );
use base  qw( XML::Writer::Namespaces );

use AutoDestroy;

sub new {
  my ($class, @args) = @_;
  my %args = @args;
  # we will have to do some cunning ISA manipulation if we don't use namespaces
  die "%s only works with namespaces\n", __PACKAGE__
    unless $args{NAMESPACES};
  my $self = XML::Writer->new(@args);
  return bless $self, $class;
}

sub startTagScope {
  # we need a closure on $self, $name; so we need a lexical pad
  my ($self, $name, @args) = @_;
  $self->startTag($name, @args);
  return auto_destroy { $self->endTag($name) }
}

1; # keep require happy
