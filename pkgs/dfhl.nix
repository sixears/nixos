{ pkgs }: pkgs.writers.writeBashBin "dfhl" ''
set -u -o pipefail
shopt -s nullglob
PATH=/dev/null

exec ${pkgs.coreutils}/bin/df \
     --human-readable --local --print-type --portability \
     --exclude-type squashfs
     --exclude-type tmpfs
     --exclude-type devtmpfs
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
