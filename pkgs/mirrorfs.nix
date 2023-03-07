{ pkgs }: pkgs.writers.writePerlBin "mirrorfs" { libraries = with pkgs.perlPackages; [ IOAll ]; } ''
use lib qw( ${pkgs.perlPackages.IOAll}/lib/perl5/site_perl/ );

use 5.28.0;

use strict;
use warnings;

use Getopt::Long qw( GetOptions );
use IO::All      qw( io );

use constant FSLISTFN => '/var/lib/mirrorfs';

my $Verbose = 0;
my ($DryRun, $NoRootCheck, $FsListFns, $ListFns, $CheckTS);
my $Exit = 0;

my @fslistfns;
GetOptions( 'fslistfn|f=s'  => \@fslistfns
          , 'dry-run|n'     => \$DryRun
          , 'verbose|v+'    => \$Verbose
          , 'no-root-check' => \$NoRootCheck
          , 'fslistfns|F'   => \$FsListFns
          , 'listfns|L'     => \$ListFns
          , 'check-ts|T'    => \$CheckTS
          )
  or die "options parsing failed\n";

if ( $DryRun ) {
  die "--listfns makes no sense with --dry-run"
    if $ListFns;
  die "--check-ts makes no sense with --dry-run"
    if $CheckTS;
}

my @fs;
if ( $FsListFns ) {
  push @fslistfns, @ARGV;
} else {
  @fs = @ARGV;
}

my %fs;

die "run as root\n"
  unless 0 == $< or $DryRun or $NoRootCheck or $ListFns or $CheckTS;

if ( @fslistfns or !@fs ) {
  @fslistfns = FSLISTFN
    unless @fslistfns or ! -e FSLISTFN;
  if ( @fslistfns ) {
    for my $fslistfn (@fslistfns) {
      for my $line (io($fslistfn)->chomp->slurp) {
        next if $line =~ /^\s*(?:#.*)?$/;
        my ($name, $opts) = split /\t+/, $line, 2;
        my %opts;
        if ( defined $opts ) {
          my @opts = split /,/, $opts;
          for my $opt (split /,/, $opts) {
            my($k,$v) = split /:/, $opt, 2;
            $opts{$k} = $v;
          }
        }
        push @fs, $name;
        $fs{$name} = \%opts;
      }
    }
  } else {
    my @mounts = qx( /run/current-system/sw/bin/mount );
    my %mount;
    for (@mounts) {
      $mount{$2} = $1
        if m!/dev/(sd\w\d+) on (/\S*) !;
    }
    for (keys %mount) {
      if ( m!^/backup\d*/([-/\w]+)$! ) {
        $fs{$1} = +{};
      }
    }
    @fs = keys %fs;
  }
}

FS:
for my $fs (@fs) {
  my $opts = $fs{$fs};
  if ( $ListFns ) {
    print "FS: $fs\n";
    next FS;
  }

  my @opts = ( '--exclude' => '.disk-label'
             , '--exclude' => '.gvfs' );
  while ( my($k,$v) = each %$opts ) {
    if ( 'exclude' eq $k ) {
      my @exclude = split ' ', $v;
      push @opts, '--exclude' => $_
        for @exclude;
    } else {
      die "unrecognized option '$k' for fs '$fs'\n";
    }
  }

  $fs =~ s!^([^/])!/$1!;
  my $from = $fs eq '/root' ? '/' : "$fs/";

  warn ("not found: '$fs'\n"), next FS
    unless -e $fs;
  my $done = 0;
  my @backupfses = qw( backup backup2 backup3 ubuntu-a ubuntu-b );
  (my $m = substr $fs, 1) =~ tr!/!-!;
  my $logfn = "/tmp/$m.mirrorlog";
  if ( $CheckTS ) {
    warn("Old mirrorlog found: $logfn\n"), $Exit = 1
      if 1.5 < -M $logfn;
  } else {
    for my $to (grep -d, map "/''${_}$fs/", @backupfses) {
      my @cmd = (rsync => '--archive', '--hard-links'
                        , '--delete-before', '--one-file-system'
                        , '--log-file' => $logfn
                        , @opts, => $from, $to);
      $done = 1;
      print "CMD: ", join(' ', @cmd), "\n"
        if $Verbose > 1;
      printf "Mirroring %-10s to %-18s", $from, "$to..."
        if $Verbose;
      unless ( $DryRun ) {
        my $rv = system @cmd;
        if ( $Verbose ) {
          print "$rv\n";
        } elsif ( $rv ) {
          warn (sprintf"failed to mirror %s to %s: %d\n", $from, $to, $rv);
        }
      } else {
        print "\n"
          if $Verbose;
      }
    }
  }
  warn "no backup location found for dir '$fs'\n"
    unless $CheckTS or $done;
}

exit $Exit;
''
# Local Variables:
# mode: perl
# End:
