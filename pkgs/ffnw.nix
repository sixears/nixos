{ pkgs }: pkgs.writers.writeBashBin "ffnw" ''
# open firefox with a new window
set -eu -o pipefail
exec ${pkgs.firefox}/bin/firefox -new-window "$@"
''

# Local Variables:
# mode: sh
# End:
