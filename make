#!/run/current-system/sw/bin/bash

set -eu -o pipefail

wrappersbin=/run/wrappers/bin
swbin=/run/current-system/sw/bin

basename=$swbin/basename
env=/usr/bin/env
getopt=$swbin/getopt
nixos_rebuild=$swbin/nixos-rebuild
sudo=$wrappersbin/sudo
systemctl=$swbin/systemctl

verbose=false
dry_run=false

# ------------------------------------------------------------------------------

warn () {
  echo -e "$1" 1>&2
}

info () {
  $verbose && echo -e "$1" 1>&2
}

die () {
  warn "$2" 1>&2
  exit "$1"
}

go() {
  exit="$1"; shift
  if $dry_run; then info "(CMD) $*"; else info "CMD> $*"; fi
  $dry_run || eval "$@" || die "$exit" "failed: $*"
}

go_exec() {
  builtin printf 'CMD> '
  builtin printf '%q ' "${@:1:$(($#-1))}"
  builtin printf '%q\n' "${@:$#}"

  echo bart
  $dry_run || exec "$@"
}

usage () {
  _usage="$(cat <<EOF
usage: $progname OPTION* [switch]

build nixos system.  If 'switch' is specified, effect it, too.

options:
 -d | --dirty       allow building from a dirty tree
 -r | --remote      work outside of sixears network
 -i | --isolated    work completely offline

 -v | --verbose
 -n | --dry-run
 --help
EOF
)"
  echo "$_usage" 1>&2
  exit 2
}


# ------------------------------------------------------------------------------

pfx_cmd=()
sfx_cmd=()
# sadly, nixos-rebuild needs /run/…/sw/bin in the path
env_add=( PATH=/run/current-system/sw/bin )
command=build
progname="$($basename "$0")"
hostname="$($swbin/hostname --short)"
isolated=false
remote=false
dirty=false

options=( -o vnird --long dirty,isolated,remote,verbose,dry-run,help )
OPTS=$( $getopt "${options[@]}" -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

while true; do
  case "$1" in
    -i | --isolated ) isolated=true ; shift ;;
    -r | --remote   ) remote=true   ; shift ;;
    -d | --dirty    ) dirty=true    ; shift ;;

    -v | --verbose  ) verbose=true ; shift   ;;
    -n | --dry-run  ) dry_run=true ; shift   ;;
         --help     ) usage                  ;;
    # !!! don't forget to update usage !!!
    -- ) shift; break ;;
    * ) break ;;
  esac
done

case $# in
  0) ;;
  1) case "$1" in
       switch) command=switch
               pfx_cmd=( $sudo -- )
               env_add+=( HOME=/root )
               ;;
       *     ) echo "invalid command: '$1'" 1>&2; exit 2;
     esac
     ;;
  *) usage ;;
esac

cmd=($nixos_rebuild --flake ~+/#$hostname --verbose $command)
if $isolated; then
  cmd+=( --offline )
elif $remote; then
  cmd+=( --option substituters https://cache.nixos.org/ )
fi

if $dirty; then
  cmd+=( --option allow-dirty true )
else
  cmd+=( --option allow-dirty false )
fi

bash_cmd="$env -i ${env_add[*]} ${cmd[*]}"
if [[ 0 -ne  ${#sfx_cmd[@]} ]]; then
  bash_cmd+=" ${sfx_cmd[*]}"
fi
go_exec "${pfx_cmd[@]}" bash -c "$bash_cmd"
