{ pkgs ? import <nixpkgs> {}, bash-header }: pkgs.writers.writeBashBin "vpn" ''

set -u -o pipefail -o noclobber;
shopt -s nullglob
shopt -s dotglob

source ${bash-header}

Cmd[journalctl]=/run/current-system/sw/bin/journalctl
#Cmd[journalctl]=/tmp/j
Cmd[systemctl]=/run/current-system/sw/bin/systemctl

export PAGER=${pkgs.less}/bin/less
# required by journalctl.  Seriously.  Read the manpage:
#
# $SYSTEMD_PAGER
#
#   Pager to use when --no-pager is not given; overrides $PAGER. If neither
#   $SYSTEMD_PAGER nor $PAGER are set, a set of well-known pager implementations
#   are tried in turn, including less(1) and more(1), until one is found. If no
#   pager implementation is discovered no pager is invoked. Setting this
#   environment variable to an empty string or the value "cat" is equivalent to
#   passing --no-pager. Note: if $SYSTEMD_PAGERSECURE is not set, $SYSTEMD_PAGER
#   (as well as $PAGER) will be silently ignored.
export SYSTEMD_PAGERSECURE=true

readonly RUN_DIR=/var/run/gdddns

# ------------------------------------------------------------------------------

main () {
  local mode="$1" service="$2" lines="$3" follow=$4

  if [[ $mode != log ]]; then
    [[ -n $lines ]] && die "-n|--lines is valid only in log mode"
    $follow && die "-f|--follow is valid only in log mode"
  fi

  case "$mode" in
    stop | start | restart )
      gocmd 10 sudo -- ''${Cmd[systemctl]} "''${args[0]}"  "$service" ;;
    status ) gocmd 11 systemctl status "$service"                     ;;
    log    )
      log_args=( --lines=''${lines:-20} )
      $follow && log_args+=( --follow )
      gocmd 12 journalctl --unit "$service" "''${log_args[@]}"        ;;
    *      ) usage                                                    ;;
  esac
}

# ------------------------------------------------------------------------------

Usage="$(''${Cmd[cat]} <<EOF
usage: $Progname <start|stop|restart|status|log> [location]

Manage the VPN on this host

options:
 -v | --verbose
 --dry-run
 --help
 --debug
EOF
)"

orig_args=("$@")
getopt_args=( -o vn:fl:
              --long lines:,location:follow,verbose,dry-run,help,debug )
OPTS=$( ''${Cmd[getopt]} "''${getopt_args[@]}" -n "$Progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

artist=""
lines=""
follow=false

location_file=/root/openvpn.default-location
location="$(gocmdnoexitnodryrun sudo ''${Cmd[cat]} $location_file 2>/dev/null)"
: ''${location:=uk_london}

while true; do
  case "$1" in
    -n | --lines    ) lines="$2"               ; shift 2 ;;
    -f | --follow   ) follow=true              ; shift   ;;
    -l | --location ) location="$2"            ; shift 2 ;;
    # !!! don't forget to update usage !!!
    -v | --verbose  ) Verbose=$((Verbose+1))   ; shift   ;;
    --help          ) usage                              ;;
    --dry-run       ) DryRun=true              ; shift   ;;
    --debug         ) Debug=true               ; shift   ;;
    --              ) args+=("''${@:2}")       ; break   ;;
    *               ) args+=("$1")             ; shift   ;;
  esac
done

debug "CALLED AS: $(showcmd "$0" "''${orig_args[@]}")"

case ''${#args[@]} in
  0 | 1 | 2 ) main "''${args[0]:-status}" "openvpn-$location" "$lines" $follow;;
  *         ) usage                                                           ;;
esac
''

# Local Variables:
# mode: sh
# End:
