{ pkgs }: pkgs.writers.writePerlBin "mlen" { libraries = with pkgs.perlPackages; [ IOAll IPCSystemSimple ]; } ''
use 5.014;
use strict;
use warnings;

use File::Basename       qw( basename fileparse );
use FindBin              qw( $Script );
use Getopt::Long         qw( GetOptions GetOptionsFromArray
                             :config no_ignore_case bundling
                                     prefix_pattern=--|- );
use IO::All              qw( io );
use IPC::System::Simple  qw( capture );
# use MP3::Info            qw( get_mp3info );

no warnings 'experimental';

my ($Stdin, $IgnoreMissing, $Fullname);

GetOptions( 'stdin|s' => \$Stdin
          , 'ignore-missing|I' => \$IgnoreMissing
          , 'fullname|F' => \$Fullname
          )

  or die "options parsing failed\n";

push @ARGV, map s/\n$//r, grep !/^\s*(#.*)?$/, <STDIN>
  if $Stdin;

die "Usage: $Script (-s|<fn>+)\n"
  unless @ARGV;

my $LINE_FMT = "%3d:%02d  %2d:%02d  %s\n";
my $total_s = 0;

# --------------------------------------

sub flac_len {
  my ($fn) = @_;

  my @metaflac_cmd = ('metaflac', '--block-type=STREAMINFO', '--list', $fn);
  my @metaflac = capture(@metaflac_cmd);
  my ($sample_rate, $secs);
  local $_;
  for $_ (@metaflac) {
    if ( /^\s*sample_rate: (\d+) Hz$/ ) {
      die "sample rate already defined to be '$sample_rate'\n"
        if $sample_rate;
      $sample_rate = $1;
    } elsif ( /^\s*total samples: (\d+)$/ ) {
      my $samples = $1;
      die "no sample rate found (total samples: '$1'\n"
        unless $sample_rate;
      $secs = int $samples / $sample_rate;
    }
  }
  return $secs;
}

# --------------------------------------

sub wav_len {
  my ($fn) = @_;

  my ($shnlen) = capture(qw( ${pkgs.shntool}/bin/shnlen -u mb -t -c ) => $fn);
  if ( $shnlen =~ m/^\s*(?<min>\d+):(?<sec>\d+)\.(?<ms>\d+)\s/ ) {
    return $+{sec} + 60*$+{min};
  } else {
    die "failed to parse shnlen output: '$shnlen'\n";
  }
}

# --------------------------------------

sub ogg_len {
  my ($fn) = @_;

  my $ogginfo = capture(qw( ${pkgs.vorbis-tools}/bin/ogginfo ) => $fn);
  if ( $ogginfo =~
       m/^\s+Playback length: (?<min>\d+)m:(?<sec>\d+)\.(?<ms>\d+)s(\s|$)/m ) {
    return $+{sec} + 60*$+{min};
  } else {
    die "failed to parse ogginfo output: '$ogginfo'\n";
  }
}

# --------------------------------------

sub mp3_len {
  my ($fn) = @_;

  my ($soxilen) = capture(qw( ${pkgs.sox}/bin/soxi -D ) => $fn);
  if ( $soxilen =~ m/^(\d+(?:\.\d*)?)$/ ) {
    return $1;
  } else {
    die "failed to parse soxi output: '$soxilen'\n";
  }
}

# --------------------------------------

my @fns =
  map { $_ =~ /\.m3u$/ ? grep !/^\s*(#.*)?$/, io($_)->chomp->slurp : $_ } @ARGV;

FN:
for my $fn (@fns) {
  next if -d $fn;
  unless ( -e $fn ) {
    my $msg = "no such file '$fn'\n";
    if ( $IgnoreMissing ) {
      warn $msg;
      next FN;
    } else {
      die $msg;
    }
  }

  my $suffix = (fileparse($fn, qr/(?<=\.)[^.]*$/))[2];

  my $secs =
    do {
      given (lc $suffix) {
        when ( 'flac' ) { flac_len($fn) }
        when ( 'wav'  ) { wav_len($fn)  }
        when ( 'ogg'  ) { ogg_len($fn)  }
        when ( 'mp3'  ) { mp3_len($fn)  }

        default             { warn "unrecognized file type: '$fn'\n" }
      }
    };

  $total_s += $secs;
  my $name = $Fullname ? $fn : basename($fn);
  printf $LINE_FMT, $total_s/60, $total_s%60, $secs/60, $secs%60, $name;
}

__END__
metaflac --block-type=STREAMINFO --list
  /music/BY-ARTIST/Frankie\ Goes\ to\ Hollywood/\[1993S02\]\ -\ Welcome\ to\ the\ Pleasuredome\ \ \(1993\ Release\)/01-Welcome\ to\ the\ Pleasuredome\ \ \(Altered\ Real\).flac | perl -nle 'if ( ($s) = /total samples: (\d+)/ ) { $e=int($s/44100); printf "%d:%02d\n", $e/60, $e%60 }'
''
# Local Variables:
# mode: perl
# End:
