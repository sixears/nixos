#!/run/current-system/sw/bin/bash

set -eu -o pipefail

swbin=/run/current-system/sw/bin

basename=$swbin/basename
getopt=$swbin/getopt
nixos_rebuild=$swbin/nixos-rebuild

# ------------------------------------------------------------------------------

usage () {
  _usage="$(cat <<EOF
usage: $progname OPTION* [switch]

build nixos system.  If 'switch' is specified, effect it, too.

options:
 -v | --verbose
 -n | --dry-run
 --help
EOF
)"
  echo "$_usage" 1>&2
  exit 2
}


# ------------------------------------------------------------------------------

verbose=false
dry_run=0

command=build
progname="$($basename "$0")"
hostname="$($swbin/hostname --short)"

options=( -o vn --long switch,verbose,dry-run,help )
OPTS=$( $getopt "${options[@]}" -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

while true; do
  case "$1" in
    -v | --verbose  ) verbose=true           ; shift   ;;
    -n | --dry-run  ) dry_run=$(($dry_run+1)) ; shift   ;;
         --help     ) usage                             ;;
    # !!! don't forget to update usage !!!
    -- ) shift; break ;;
    * ) break ;;
  esac
done

case $# in
  0) ;;
  1) case "$1" in
       switch) command=switch ;;
       *     ) echo "invalid command: '$1'" 1>&2; exit 2;
     esac
     ;;
  *) usage ;;
esac

cmd=($nixos_rebuild --flake ~+/#$hostname --verbose $command) # --option substituters https://cache.nixos.org # --offline
if $verbose; then
  builtin printf 'CMD> '
  for i in "${cmd[@]:0:$((${#cmd[@]}-2))}"; do
    builtin printf '%q ' "$i"
  done
  builtin printf '%q\n' "${cmd[@]:$((${#cmd[@]}-1))}"
fi

if [[ 0 -eq $dry_run ]]; then
  ${cmd[@]}
fi
