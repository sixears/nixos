#!/run/current-system/sw/bin/bash

set -eu -o pipefail

wrappersbin=/run/wrappers/bin
swbin=/run/current-system/sw/bin

basename=$swbin/basename
dirname=$swbin/dirname
env=/usr/bin/env
getopt=$swbin/getopt
nixos_rebuild=$swbin/nixos-rebuild
sudo=$wrappersbin/sudo
systemctl=$swbin/systemctl

verbose=false
dry_run=false

hostnames=()
progname="$(basename "$(command realpath -e "$0")")"
progdir="$(dirname "$(command realpath -e "$0")")"

# ------------------------------------------------------------------------------

warn () { echo -e "$1" 1>&2; }

info () { $verbose && echo -e "$1" 1>&2; }

die () { warn "$2" 1>&2; exit "$1"; }

go() {
  exit="$1"; shift
  if $dry_run; then info "(CMD) $*"; else info "CMD> $*"; fi
  $dry_run || "$@" || die "$exit" "failed: $*"
}

go_exec() {
  builtin printf 'CMD> '
  builtin printf '%q ' "${@:1:$(($#-1))}"
  builtin printf '%q\n' "${@:$#}"

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
 -T | --show-trace
 -h | --hostname    use this hostname (instead of $hostname)
 -I | --impure      enable impure evaluation

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
isolated=false
remote=false
dirty=false
show_trace=false
impure=false

options=( -o vnirdTh:I
          --long show-trace,dirty,isolated,remote,hostname:,impure
          --long verbose,dry-run,help )
OPTS=$( $getopt "${options[@]}" -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

while true; do
  case "$1" in
    -i | --isolated   ) isolated=true      ; shift   ;;
    -r | --remote     ) remote=true        ; shift   ;;
    -d | --dirty      ) dirty=true         ; shift   ;;
    -T | --show-trace ) show_trace=true    ; shift   ;;
    -h | --hostname   ) hostnames=( "$2" ) ; shift 2 ;;
    -I | --impure     ) impure=true        ; shift   ;;

    -v | --verbose    ) verbose=true       ; shift   ;;
    -n | --dry-run    ) dry_run=true       ; shift   ;;
         --help       ) usage                        ;;
    # !!! don't forget to update usage !!!
    -- ) shift; break ;;
    * ) break ;;
  esac
done

case $# in
  0) ;;
  1) case "$1" in
       switch)
         command=switch
         pfx_cmd=( $sudo -- )
         env_add+=( HOME=/root )
         ;;

       checkall | check-all )
         command=dry-build
         if [[ 0 -ne ${#hostnames[@]} ]]; then
           die 2 "--hostname is invalid with checkall"
         fi
         ;;

       *     ) echo "invalid command: '$1'" 1>&2; exit 2 ;;
     esac
     ;;
  *) usage ;;
esac

cmd=($nixos_rebuild --verbose $command)
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

$show_trace && cmd+=( --show-trace )
$impure     && cmd+=( --impure )

if [[ dry-build == $command ]]; then
  hostfiles=( "$progdir/hosts/"*.nix )
  hostnames=( $($basename --multiple "${hostfiles[@]%.nix}") )
fi
[[ 0 -eq ${#hostnames[@]} ]] && hostnames=( "$($swbin/hostname --short)" )

for hostname in "${hostnames[@]}"; do
  this_cmd=( "${cmd[@]}" )
  this_cmd+=( --flake ~+/#$hostname )

  bash_cmd="$env -i ${env_add[*]} ${this_cmd[*]}"
  if [[ 0 -ne  ${#sfx_cmd[@]} ]]; then
    bash_cmd+=" ${sfx_cmd[*]}"
  fi
  go 10 "${pfx_cmd[@]}" bash -c "$bash_cmd"
done
