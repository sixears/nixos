{ pkgs }: pkgs.writers.writePerlBin "mirrorfs" { libraries = with pkgs.perlPackages; [ IOAll ]; } ''

# much like a simple `host` re-implementation, but returns non-zero for names
# that cannot be resolved

use 5.28.0;

use strict;
use warnings;

use FindBin      qw( $Script );
use Getopt::Long qw( GetOptions );
use Socket       qw( inet_ntoa );

my $silent;
GetOptions( 'silent'  => \$silent
          )
  or die "options parsing failed\n";
die "usage: $Script [--silent] <HOST>+\n"
  unless @ARGV;

for my $ARGV (@ARGV) {
  my $result = gethostbyname($ARGV);
  if ( $result ) {
    say "$ARGV\t", inet_ntoa($result)
      unless $silent;
  } else {
    if ( $silent ) {
       exit 255;
    } else {
      die "failed to resolve $ARGV: $!\n";
    }
  }
}
''
# Local Variables:
# mode: perl
# perl-indent-level: 2
# End:
