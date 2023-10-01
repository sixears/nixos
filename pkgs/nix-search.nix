{ pkgs }: pkgs.writers.writeBashBin "nix-search" ''
# search $NIXPKGS for a pkg
set -eu -o pipefail

# cut=${pkgs.coreutils}/bin/cut
jq=${pkgs.jq}/bin/jq
perl=${pkgs.perl}/bin/perl

# nix search $NIXPKGS --json "$@" | $jq -r 'keys|.[]' | $cut -d . -f 3-
nix search $NIXPKGS --json "$@"  | jq -r 'keys[] as $k | "\(.[$k] | .pname )'$'\t'''\($k)'$'\t'''\(.[$k] | .description )"' | $perl -MData::Dumper -MList::Util=max -nlaF/\\t/ -E 'push @x, [ @F ]; $i=0; for $f (@F) { $w[$i]=max length($f),($w[$i]//0);$i++; }; END{for my $x (@x) { for my $i (0..$#$x) { my $w = $w[$i]; printf "%-''${w}s", $x->[$i]; printf "\t" unless $i == $#$x; } say } }'
''

# Local Variables:
# mode: sh
# End:
