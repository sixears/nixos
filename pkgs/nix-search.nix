{ pkgs }: pkgs.writers.writeBashBin "nix-search" ''
# search $NIXPKGS for a pkg
set -eu -o pipefail

cut=${pkgs.coreutils}/bin/cut
jq=${pkgs.jq}/bin/jq

nix search $NIXPKGS --json "$@" | $jq -r 'keys|.[]' | $cut -d . -f 3-
''

# Local Variables:
# mode: sh
# End:
