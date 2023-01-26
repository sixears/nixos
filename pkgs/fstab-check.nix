{ pkgs }: pkgs.writers.writeBashBin "fstab-check" ''

cut=${pkgs.coreutils}/bin/cut
grep=${pkgs.gnugrep}/bin/grep
id=${pkgs.coreutils}/bin/id
tail=${pkgs.coreutils}/bin/tail

warn () {
  echo -e "$1" 1>&2
}

fstab="''${1:-/etc/fstab}"

errors=$(
  $grep ^/ "$fstab" | while read -r dev mnt _ opts _ _; do
    if $grep --word-regexp bind <( echo "$opts" ); then
      if [ ! -e "$dev" ]; then
        warn "bind mount of non-existent directory '$dev'"
        if [ "$( $id --user )" -ne 0 ]; then
          warn "  this might be because you are not running as root"
        fi
      elif [ ! -d "$dev" ]; then
        warn "bind mount of non-directory '$dev'"
      fi
    elif [ ! -e "$dev" ]; then
      warn "does not exist: '$dev'"
      errors=$((errors+1))
    elif [ ! -L "$dev" ]; then
      warn "not a symlink: '$dev'"
      errors=$((errors+1))
    else
      target="$(readlink --canonicalize-existing "$dev")"
      if [ ! -b "$target" ]; then
        warn "not a block device: '$target' ($dev)"
      fi
      echo "TARGET: $target $dev $mnt"
    fi
    echo "ERRORS: $errors"
  done
)

$grep ^TARGET: <( echo "$errors" ) | while read -r _ target dev mnt; do
  declare -A tgt mnts
  if [ -n "''${tgt["$target"]}" ]; then
    warn "target '$target' is referenced by '$mnt' ($dev) and '""''${mnts["$target"]} (''${tgt["$target"]})"
  fi
  tgt["$target"]="$dev"
  mnts["$target"]="$mnt"
done

es="$( $tail -n 1 <( echo "$errors" ) | $cut -c 9- )"
exit "''${es:-0}"
''

# Local Variables:
# mode: sh
# End:
