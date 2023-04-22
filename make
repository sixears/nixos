#!/run/current-system/sw/bin/bash

set -u -o pipefail

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
  $dry_run || "$@" || [[ -z $exit ]] || die "$exit" "failed: $*"
}

usage () {
  _usage="$(cat <<EOF
usage: $progname OPTION* [switch|checkall]

build nixos system.  If 'switch' is specified, effect it, too.

If 'checkall' is specified; then check all the host configs, one-by-one.
Implies --dirty.

options:
 -d | --dirty       allow building from a dirty tree
 -r | --remote      work outside of sixears network
 -i | --isolated    work completely offline
 -T | --show-trace
 -h | --hostname    use this hostname (instead of $($swbin/hostname --short))
 -I | --impure      enable impure evaluation
 -N | --bincache    explicitly cite 192.168.0.7 as a substituters
 -S | --sudo        force sudo, needed to trust without keys

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
very_verbose=false
substituters=( https://cache.nixos.org/ )

options=( -o vnirdTh:IVNS
          --long show-trace,dirty,isolated,remote,hostname:,impure,very-verbose,bincache,sudo
          --long verbose,dry-run,help )
OPTS=$( $getopt "${options[@]}" -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

while true; do
  case "$1" in
    -i | --isolated   ) isolated=true        ; shift   ;;
    -r | --remote     ) remote=true          ; shift   ;;
    -d | --dirty      ) dirty=true           ; shift   ;;
    -T | --show-trace ) show_trace=true      ; shift   ;;
    -h | --hostname   ) hostnames=( "$2" )   ; shift 2 ;;
    -I | --impure     ) impure=true          ; shift   ;;
    -N | --bincache   ) substituters+=( http://nixos-bincache.sixears.co.uk:5000/ ); shift ;;
    -S | --sudo       ) pfx_cmd=( $sudo -- ) ; shift   ;;

    -v | --verbose    ) verbose=true         ; shift   ;;
    -V | --very-verbose ) very_verbose=true  ; shift   ;;
    -n | --dry-run    ) dry_run=true         ; shift   ;;
         --help       ) usage                          ;;
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
         dirty=true
         if [[ 0 -ne ${#hostnames[@]} ]]; then
           die 2 "--hostname is invalid with checkall"
         fi
         ;;

       * ) echo "invalid command: '$1'" 1>&2; exit 2 ;;
     esac
     ;;
  *) usage ;;
esac

cmd=($nixos_rebuild $command)
if $isolated; then
  cmd+=( --offline )
elif $remote; then
  substituters=( https://cache.nixos.org/ )
fi

if $dirty; then
  cmd+=( --option allow-dirty true )
else
  cmd+=( --option allow-dirty false )
fi

$very_verbose && cmd+=( --verbose )

$show_trace && cmd+=( --show-trace )
$impure     && cmd+=( --impure )

if [[ 0 -ne ${#substituters[@]} ]]; then
  cmd+=( --option substituters "'${substituters[*]}'" )
fi

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

  if [[ dry-build == $command ]]; then
    warn "checking $hostname..."
    go '' "${pfx_cmd[@]}" bash -c "$bash_cmd"
    echo "exit: $?"
  else
    go 10 "${pfx_cmd[@]}" bash -c "$bash_cmd"
  fi
done
# https://nixos.wiki/wiki/Nixos-rebuild
## /usr/bin/env -i SSH_AUTH_SOCK=/tmp/martyn/ssh-XXXXXX6Lxt15/agent.2771 PATH=/run/current-system/sw/bin /run/current-system/sw/bin/nixos-rebuild --option allow-dirty false --verbose --flake /home/martyn/nixos/#grain --target-host grain --use-remote-sudo switch
# nixos-rebuild  --verbose --flake ~+/#night --target-host night --use-remote-sudo switch
