package XML::RSS::Podcast;

# ripped from http://taskboy.com/blog/index.php?bid=1086 by Joe Johnston

# pragmata ----------------------------

use strict;
use warnings;

# inheritance -------------------------

use ParamCheck    qw( );
use XML::AutoTag  qw( );
use XML::RSS      qw( );

use base  qw( XML::RSS ParamCheck XML::AutoTag );

# utility -----------------------------

use AutoDestroy;
use HTML::Entities       qw( encode_entities_numeric encode_entities );
use Tie::Hash::Fixed     qw( );
use XML::Writer::Scopes  qw( );

# CLASS OBJECT ---------------------------------------------------------------

# -------------------------------------
# CLASS CONSTANTS
# -------------------------------------

our $VERSION = 1.1;

use constant ITUNES_NS =>  'http://www.itunes.com/dtds/podcast-1.0.dtd';

tie my %NS, 'Tie::Hash::Fixed',
 +{ itunes => 'http://www.itunes.com/dtds/podcast-1.0.dtd',
    atom   => 'http://www.w3.org/2005/Atom'
  };

use constant CHANNEL_FIELDS     => qw( ttl title description link language
                                       pubDate lastBuildDate creator webMaster
                                       copyright );
use constant IMAGE_FIELDS       => qw( title url description link width
                                       height );
use constant ITUNES_FIELDS      => qw( subtitle author summary image explicit );
use constant ITEM_FIELDS        => qw( title guid pubDate description link );
use constant ITUNES_ITEM_FIELDS => [qw( author subtitle summary duration
                                        keywords explicit )];
use constant ITUNES_NAME_FIELDS => [qw( name email )];
use constant ENCLOSURE_FIELDS   => [qw( url length type )];

# INSTANCE OBJECT ------------------------------------------------------------

sub new {
  my ($class, %args) = @_;
  # feed loc is feed location; i.e., the primary URL of the podcast.
  # the RSS specs recommend this in an atom tag
  # http://feedvalidator.org/docs/warning/MissingAtomSelfLink.html
  my $feedloc = delete $args{feedloc}
    or warn "no feed location provided\n";
  my $self = $class->SUPER::new(%args);
  $self->{feedloc} = $feedloc
    if defined $feedloc;

  return $self;
}

# -------------------------------------

sub _xmlwriter  { $_[0]->{xmlwriter} }
sub _xmltext    { ${$_[0]->_xmlwriter->getOutput} }
sub _data_tag   { $_[0]->_xmlwriter->dataElement(@_[1..$#_]) }
sub _empty_tag  { $_[0]->_xmlwriter->emptyTag(@_[1..$#_]) }
sub _start_itag { $_[0]->_xmlwriter->startTag([$NS{itunes}, $_[1]], @_[2..$#_]) }
sub _end_itag   { $_[0]->_xmlwriter->endTag([$NS{itunes}, $_[1]]) }
sub _empty_itag { $_[0]->_xmlwriter->emptyTag([$NS{itunes}, $_[1]], @_[2..$#_]) }

# -------------------------------------

# sub _write_data_fields : CheckP(_,S?,HR?,AR;HR?) {
sub _write_data_fields : CheckP(qw( _ S? HR? AR ; HR? )) {
  my ($self, $ns, $hr, $fields, $add_attrs) = @_;
  return unless defined $hr;
  # we use defined rather than exists so callers can explicitly initialize
  # the hash with ..., name => undef, ... to show that they haven't forgotten
  # the field altogether.  We don't test for truth because '' is a valid value
  local $_;
  for $_ (grep defined $hr->{$_}, @$fields) {
    my @attrs = exists $add_attrs->{$_} ? @{$add_attrs->{$_}} : ();
    my $tagname = $ns ? [ $ns, $_ ] : $_;
    $self->_data_tag($tagname, $hr->{$_}, @attrs);
  }
}

# -------------------------------------

sub _write_tag_fields : CheckP(_,S,HR?,AR) {
  my ($self, $tag_name, $hr, $fields) = @_;
  return unless defined $hr;
  # we use defined rather than exists so callers can explicitly initialize
  # the hash with ..., name => undef, ... to show that they haven't forgotten
  # the field altogether.  We don't test for truth because '' is a valid value
  $self->_empty_tag($tag_name, map +($_, $hr->{$_}),
                              grep defined $hr->{$_}, @$fields);
}

# -------------------------------------

sub _write_idata_fields { $_[0]->_write_data_fields($NS{itunes},@_[1..$#_]) }

# -------------------------------------

sub as_string {
  my $xmltext = '';
  $_[0]->{xmlwriter} =
    XML::Writer::Scopes->new(OUTPUT          => \$xmltext,
                             DATA_MODE       => 1,
                             DATA_INDENT     => 2,
                             NAMESPACES      => 1,
                             PREFIX_MAP      => +{ reverse %NS },
                             FORCED_NS_DECLS => [ values %NS ],
                            );

  $_[0]->_xmlwriter->xmlDecl($_[0]->{encoding});
  $_[0]->_write_rss;
  return $_[0]->_xmltext;
  delete $_[0]->{xmlwriter};
}

# -------------------------------------

sub _write_rss : TAG(rss( version => 2.0 )) { $_[0]->_write_channels }

# -------------------------------------

sub _write_channels : TAG(channel) {
  my ($self) = @_;

  $self->_write_channel_data;
  $self->_write_item($_)
    for @{$self->{items}};
}

# -------------------------------------

sub _write_channel_data {
  my ($self) = @_;

  my $writer = $self->_xmlwriter;

  $self->_empty_tag([$NS{atom}, 'link'], href => $self->{feedloc},
                                         rel => 'self',
                                         type => 'application/rss+xml' )
    if exists $self->{feedloc};

  my $channel = $self->{channel};
  $self->_data_tag($_ => $channel->{$_})
    for grep defined $channel->{$_}, CHANNEL_FIELDS;
  $self->_data_tag([$NS{itunes}, 'explicit'] => 'no');

  my $seen_image = 0;
  for my $f (IMAGE_FIELDS) {
    if (defined($self->{image}->{$f})) {
      unless ($seen_image) {
        $writer->startTag('image');
        $seen_image = 1;
      }
      $self->_data_tag($f => $self->{image}->{$f});
    }
  }

  if ($seen_image) {
    $writer->endTag('image');
  }

  my $itunes = $self->{channel}->{itunes};
  $self->_data_tag([ $NS{itunes}, $_ ] => $itunes->{$_})
    for grep defined $itunes->{$_}, ITUNES_FIELDS;

  $self->_write_channel_owner($itunes);
  $self->_write_channel_category($itunes->{category});
}

# -------------------------------------

sub _write_channel_category {
  my ($self, $category) = @_;

  if ( UNIVERSAL::isa($category, 'ARRAY') ) {
    my @x; # scope placeholder for AutoDestroy objects
    for my $c (@$category[0..$#$category-1]) {
      $self->_start_itag('category', text => $c);
      # order of destroy doesn't matter here, as all destroy actions are the
      # same
      push @x, auto_destroy { $self->_end_itag('category') };
    }

    $self->_empty_itag('category', text => $category->[-1] );
  } else {
    $self->_empty_itag('category', text => $category)
  }
}

# -------------------------------------

sub _write_channel_owner : TAG([ITUNES_NS,owner])
  { $_[0]->_write_idata_fields($_[1], ITUNES_NAME_FIELDS) }

# -------------------------------------

sub _write_item : CheckP(_,HR) : TAG('item') {
  my($self, $item) = @_;

  my $writer = $self->_xmlwriter;

  # check explicit is 'yes', 'no', or 'clean'
  # http://feedvalidator.org/docs/error/InvalidYesNoClean.html
  $self->_value_check('item: explicit', $item->{explicit},
                      [undef, qw( yes no clean )]);

  $self->_write_data_fields(undef, $item, [ITEM_FIELDS], 
                            +{ guid => [ isPermaLink => 'false' ] });
  $self->_write_enclosure($item->{enclosure});
  $self->_write_idata_fields($item->{itunes}, ITUNES_ITEM_FIELDS);
}

# -------------------------------------

sub _value_check {
  my ($self, $name, $value, $legit) = @_;
  no warnings 'uninitialized';
  die sprintf "value '%s' is not a legal value for $name\n", $value // '*undef*'
    unless grep $_ eq $value, @$legit;
}

# -------------------------------------

sub _write_enclosure
  { $_[0]->_write_tag_fields('enclosure', $_[1], ENCLOSURE_FIELDS) }

# ----------------------------------------------------------------------------

1; # keep require happy
