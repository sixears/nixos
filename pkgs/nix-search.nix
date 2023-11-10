{ pkgs, tablify }: pkgs.writers.writeBashBin "nix-search" ''
# search $NIXPKGS for a pkg
set -eu -o pipefail

# cut=${pkgs.coreutils}/bin/cut
jq=${pkgs.jq}/bin/jq
perl=${pkgs.perl}/bin/perl
tablify=${tablify}/bin/tablify

# nix search $NIXPKGS --json "$@" | $jq -r 'keys|.[]' | $cut -d . -f 3-
nix search $NIXPKGS --json "$@"  | $jq -r 'keys[] as $k | "\(.[$k] | .pname )'$'\t'''\($k)'$'\t'''\(.[$k] | .description )"' | $tablify
''

# Local Variables:
# mode: sh
# End:
