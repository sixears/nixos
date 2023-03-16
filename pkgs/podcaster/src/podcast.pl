#! @perl@/bin/perl

# pragmata ----------------------------

use strict;
use warnings;

use lib qw( @out@/perllib );
use lib qw( @perllibs@ );

# nix-shell -i perl -p perl MP3Info perlPackages.XMLRSS

# utility -----------------------------

use Env                    qw( $PODCAST_CONF_DIR $QUERY_STRING $SCRIPT_NAME );
use File::Basename         qw( basename );
use File::Glob             qw( bsd_glob );
use File::Spec::Functions  qw( catfile rel2abs );
use FindBin                qw( $Bin $RealBin $Script );
use Getopt::Long           qw( GetOptions :config bundling
                                                  no_ignore_case
                                                  prefix_pattern=--|- );
use IO::All                qw( io );
use POSIX                  qw( strftime );
use MP3::Info              qw( get_mp3info );
use YAML                   qw( );

use lib "$RealBin/../perllib";
use XML::RSS::Podcast      qw( );

# constants ------------------------------------------------------------------

use constant RFC822_DATEFMT => '%a, %d %b %Y %H:%M:%S GMT';

# ----------------------------------------------------------------------------

my $confdir  = $PODCAST_CONF_DIR // '/htdocs';
my $base_url = $SCRIPT_NAME // '/podcast'; # SCRIPT_NAME is set by CGI
GetOptions( 'd|confdir=s'  => \$confdir
          , 'b|base-url=s' => \$base_url
          );

open my $logfh, '>', "/tmp/podcast.log";
say $logfh "confdir: $confdir";

# warn "$_\t$ENV{$_}\n" for sort keys %ENV;

if ( 0 == @ARGV and ! defined $QUERY_STRING ) {
  if ( -e "$confdir/$Script.yaml" ) {
    # for webserver usage, pretend that $Script was the conf name
    push @ARGV, $Script;
  } else {
    # issue a listing of available feeds
    print "Content-Type: text/html\n\n<html>\n  <body>\n    <h1>Podcasts</h1>\n    <ul>\n";
    for my $fn (bsd_glob(catfile $confdir, '*.yaml')) {
      my $conf = YAML::LoadFile($fn);
      my $nm = basename $fn, '.yaml';
      print qq'    <li><a href="$base_url?name=$nm">$conf->{title}</a></li>\n';
    }
    print "    </ul>\n  </body>\n</html>\n";
    exit 0;
  }
}


die "usage: $Script [-b URL_BASE] ( [-d CONFDIR] | [CONFNAME] )\n"
  unless @ARGV == 1 or defined $QUERY_STRING;

my $conffn;
if ( defined $QUERY_STRING and $QUERY_STRING =~ /^name=(\w+)$/ ) {
  $conffn = rel2abs "$1.yaml", $confdir;
} else {
  ($conffn) = @ARGV                                                           ?
               (index($ARGV[0],'/') == -1 ?
                  rel2abs("$ARGV[0].yaml", $confdir) : $ARGV[0])              :
               rel2abs(basename($Script, qr/.(cgi|pl)$/) . '.yaml', $confdir) ;
}

die "no such conffn: $conffn\n"
  unless -e $conffn;

my $conf = YAML::LoadFile($conffn);
my ($title, $subtitle, $category, $description, $explicit,
    $author, $owner, $email, $copyright,
    $base, $dirname, $feedloc) = @{$conf}{qw( title subtitle category description
                                              explicit author owner email copyright
                                              base dir feedloc )};
$description ||= $title;

die "no such dir: $dirname\n"
  unless -e $dirname;

print "Content-Type: application/rss+xml\n\n";

my $rss = XML::RSS::Podcast->new(version => 2.0, feedloc  => $feedloc);

$rss->channel(title       => $title,
              # "ttl"       => 60, # time to live
              link        => $base,
              language    => 'en-us',
              description => $description,
              copyright   => $copyright,
              # webMaster   => "jjohn@pseudocertainty.com",
              pubDate     => strftime(RFC822_DATEFMT, gmtime),
              itunes      => +{ author   => $author,
                                summary  => $description,
                                subtitle => $subtitle,
                                category => $category,
                                name     => $owner,
                                email    => $email,
                              },
             );

sub min { my $a = $_[0]; for my $i (1..$#_) { $a = $_[$i] if $_[$i] < $a }; return $a }
my $mp3;
my @a = sort { $b->mtime <=> $a->mtime }
             (io($dirname)->filter(sub { /\.(?:mp3|m4a)$/i })->all);
# my @b = @a[0..min(20,$#a)];
# for $mp3 ((sort { $b->mtime cmp $a->mtime } @b)) {
for $mp3 (@a) {
  if ( my($name,$date) = ($mp3 =~ /^(.*)-(\d{4}-\d{2}-\d{2})\.mp3$/i) ) {

    my $desc = "$title ($date)";
    my $link = join '/', $base, $mp3->filename;
    my ($yy, $mm, $dd) = split /-/, $date;

    $rss->add_item(title       => $date,
                   link        => $link,
                   guid        => $link,
                   description => $desc,
                   pubDate     => strftime(RFC822_DATEFMT,
                                           0, 30, 18, $dd, $mm-1, $yy-1900),
                   itunes      =>
                     +{ duration => get_mp3info($mp3->name)->{TIME},
                        summary  => $desc,
                        # keywords => "comedy BBC Radio4",
                        explicit => $explicit,
                      },
                   enclosure   =>
                     +{ url    => $link,
                        length => $mp3->size,
                        type   => 'audio/mpeg',
                      },
                  );
  } elsif ( my($nme,$series,$episode) =
              ($mp3 =~ /^(.*) - s(\d+)e(\d+) - .*\.m4a$/i) ) {

    my $desc = "$title (${series}x$episode)";
    (my $link = join '/', $base, $mp3->filename) =~ s/ /%20/g;
#    my ($yy, $mm, $dd) = split /-/, $date;

    $rss->add_item(title       => $date,
                   link        => $link,
                   guid        => $link,
                   description => $desc,
#                   pubDate     => strftime(RFC822_DATEFMT,
#                                           0, 30, 18, $dd, $mm-1, $yy-1900),
                   itunes      =>
                     +{ duration => 0, # get_mp3info($mp3->name)->{TIME},
                        summary  => $desc,
                        # keywords => "comedy BBC Radio4",
                        explicit => $explicit,
                      },
                   enclosure   =>
                     +{ url    => $link,
                        length => $mp3->size,
                        type   => 'audio/mpeg',
                      },
                  );
  } else {
    (my $name = $mp3->filename) =~ s/\.mp3$//;
    $name =~ tr/_/ /;
    my $link = join '/', $base, $mp3->filename;
    my ($dd, $mm, $yy) = (gmtime $mp3->ctime)[3,4,5];

    $rss->add_item(title       => $name,
                   link        => $link,
                   guid        => $link,
                   description => $name,
                   pubDate     => strftime(RFC822_DATEFMT,
                                           0, 30, 18, $dd, $mm, $yy),
                   itunes      =>
                     +{ duration => get_mp3info($mp3->name)->{TIME},
                        summary  => $name,
                        explicit => $explicit,
                      },
                   enclosure   =>
                     +{ url    => $link,
                        length => $mp3->size,
                        type   => 'audio/mpeg',
                      },
                  );


    warn "failed to parse ", $mp3->filename, "\n";
  }
}

print $rss->as_string, "\n";
