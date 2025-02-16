{ pkgs }: pkgs.writers.writeBashBin "wifi" ''
# -u: Treat unset variables and parameters other than the special parameters "@"
#     and "*" as an error when performing parameter expansion.  If expansion is
#     attempted on an unset variable or parameter, the shell prints an error
#     message, and, if not interactive, exits with a non-zero status.

# -o pipefail: If set, the return value of a pipeline is the value of the last
#              (rightmost) command to exit with a non-zero status, or zero if
#              all commands in the pipeline exit successfully.  This option is
#              disabled by default.

builtin set -u -o pipefail

# nullglob: If set, bash allows patterns which match no files to expand to a
#           null string, rather than themselves.
# dotglob:  If set, bash includes filenames beginning with a . in the results of
#           pathname expansion.
builtin shopt -s nullglob
builtin shopt -s dotglob

basename=${pkgs.coreutils}/bin/basename
false=${pkgs.coreutils}/bin/false
getopt=${pkgs.utillinux}/bin/getopt
true=${pkgs.coreutils}/bin/true

progname="$($basename "$0")"
verbose=$false
dry_run=$false

declare -A CMD
CMD[cut]=${pkgs.coreutils}/bin/cut
CMD[grep]=${pkgs.gnugrep}/bin/grep
CMD[ip]=${pkgs.iproute2}/bin/ip
CMD[jq]=${pkgs.jq}/bin/jq
CMD[nmcli]=${pkgs.networkmanager}/bin/nmcli
CMD[perl]=${pkgs.perl}/bin/perl

readonly -a DNS_SERVERS=( 192.168.0.7 192.168.0.24 )

# ------------------------------------------------------------------------------

warn () {
  echo -e "$1" 1>&2
}

info () {
  if $verbose; then
    echo -e "$1" 1>&2
  fi
}

# ------------------------------------------------------------------------------

connect() {
  local password="$1" name=( "''${@:2}" )

  for i in "''${name[@]}"; do
    echo "NAME: '$i'"
  done

  if [[ -n $password ]]; then
    go 7 nmcli device wifi connect "''${name[*]}" password "$password"
  else
    go 4 nmcli device wifi connect "''${name[*]}"
  fi
}

# --------------------------------------

setup() {
  local ssid="$1" ipaddr="$2" password="$3" ethernet="$4" no_up="$5"

  if [[ $ipaddr =~ ^192.168.0.([0-9]{1,3})$ ]]; then
    if [[ ''${BASH_REMATCH[1]} -ge 255 ]] || [[ ''${BASH_REMATCH[1]} -le 1 ]] ; then
      die 18 "ip address out-of-range '$ipaddr' (''${BASH_REMATCH[1]})"
    fi
  else
    die 19 "bad ip address '$ipaddr'"
  fi

  if $ethernet; then
    if ! ''${CMD[nmcli]} --terse --get-values name --mode tabular conn show | \
           ''${CMD[grep]} --quiet --line-regex --fixed-strings "$ssid"; then
      local ifname="$(go 22 ip -json address | \
                        go 23 jq -r '.[] | .ifname | select(test("^en"))' )"
      [[ $? -ne 0 ]] && die $? "ip | jq failed"
      if [[ -z $ifname ]]; then
        die 22 "no ethernet interface found"
      else
        go 21 nmcli connection add con-name "$ssid" type ethernet ifname "$ifname"
      fi
    fi
  else
    connect "$password" "$ssid"
  fi

  local mod_args=( ipv4.method manual
                   ipv4.addresses $ipaddr/24
                   ipv4.gateway 192.168.0.1
                   +ipv4.routes 192.168.0.0/24
                   ipv4.dns "''${DNS_SERVERS[*]}"
                   ipv4.dns-search sixears.co.uk
                   ipv4.dns-options edns0
                 )
  go 20 nmcli connection modify "$ssid" "''${mod_args[@]}"
  $no_up || go 23 nmcli connection up "$name"


#     IP=192.168.0.XX
#     nmcli con add con-name sixears ifname "$(ip a | grep -E '^[[:digit:]]' | cut -d ' ' -f 2 | cut -d : -f 1 | grep ^en)" type ethernet ip4 $IP/24 gw4 192.168.0.1 # you may need to work out the ethernet link by hand, if you have the HP USB Dongle attached. Or maybe the dongle is the interface?
#     nmcli con mod sixears +ipv4.routes 192.168.0.0/24
#     nmcli con mod sixears ipv4.dns '192.168.0.7 192.168.0.24'
#     nmcli con mod sixears ipv4.dns-search sixears.co.uk
#     nmcli con mod sixears ipv4.dns-options edns0
#     nmcli conn up sixears # you may have to do this at the end, if you’re connected over the dongle
#     nmcli conn del 'Wired connection 1' # you may have to do this at the end, if you’re connected over the dongle

}

# ------------------------------------------------------------------------------

usage () {
  usage="$(cat <<EOF
usage: $progname OPTION* COMMAND?

manage wifi connection

Commands:
  list                   - list the available WiFi networks (SSIDs) in range
  status                 - show current wifi networking status
  more-status            - show current wifi networking status, with more detail
  connections            - show the pre-defined connections available
  on                     - turn wifi on
  off                    - turn wifi off (aeroplane mode)
  delete SSID            - delete a pre-defined connection
  up SSID                - bring up a pre-defined connection (will take down any
                           current wifi connection)
  down SSID              - take down the named connection (will do nothing if
                           the named connection is not active)

  connect SSID [--password|-p PASSWORD]
                         - connect to a (new) SSID.  *This will not work for a
                           pre-defined connection (list them with
                           'connections'); use 'up' to bring that up, or delete
                           & re-connect to change a password

  setup SSID IPADDR [--ethernet|-e]
                         - configure a pre-defined network, using the given IPv4
                           currently, Architecture is the only available SSID
                           --ethernet avoids the initial wifi connection, and
                           sets the type to ethernet


options:
 -v | --verbose
 -n | --dry-run
 -h | --help
EOF
)"
  die 2 "$usage"
}

die() {
  warn "$2"
  exit $1
}

go() {
  local exit="$1" args=( "''${@:3}" )
  if [[ -v CMD[$2] ]]; then
    exe="''${CMD[$2]}"
  else
    die 250 "no known executable: '$2' to $FUNCNAME"
  fi
  local cmd=( "$exe" "''${args[@]}" )
  local cmdstr="''${cmd[*]@Q}"
  if $dry_run; then info "(CMD) $cmdstr"; else info "CMD> $cmdstr"; fi
  $dry_run || "''${cmd[@]}" || die "$exit" "failed ($?): $*"
}

# ------------------------------------------------------------------------------

getopt_opts=( -o vhnp:eu --long verbose,dry-run,help,password:,ethernet,no-up )
OPTS=$( $getopt "''${getopt_opts[@]}" -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

password=""
ethernet=false
no_up=false

while true; do
  case "$1" in
    -v | --verbose    ) verbose=$true ; shift   ;;
    -h | --help       ) usage                   ;;
    -n | --dry-run    ) dry_run=$true ; shift   ;;
    -p | --password   ) password="$2" ; shift 2 ;;
    -e | --ethernet   ) ethernet=true ; shift   ;;
    -u | --no-up      ) no_up=true    ; shift   ;;
    # !!! don't forget to update usage !!!
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [[ -n $password ]]; then
  if [[ $# -eq 0 ]]; then
    die 2 "--password|-p makes no sense without a command"
   elif [[ $1 != connect ]] && [[ $1 != setup ]]; then
    die 2 "--password|-p makes no sense with command '$1'"
   fi
fi

if $ethernet; then
  if [[ $# -eq 0 ]]; then
    die 2 "--ethernet|-e makes no sense without a command"
   elif [[ $1 != setup ]]; then
    die 2 "--ethernet|-e makes no sense with command '$1'"
   fi
fi

if $no_up; then
  if [[ $# -eq 0 ]]; then
    die 2 "--no-up|-u makes no sense without a command"
   elif [[ $1 != setup ]]; then
    die 2 "--no-up|-u makes no sense with command '$1'"
   fi
fi

if [ $# -eq 0 ]; then
  if [ "x$(''${CMD[nmcli]} radio wifi)" != "xenabled" ]; then
    if [ -t 0 ]; then
      die 17 "\033[91mwifi is not enabled; use 'wifi on' to turn it on!\033[0m"
    else
      die 17 "wifi is not enabled; use 'wifi on' to turn it on!"
    fi
  else
    go 3 nmcli device wifi list
  fi
elif [ "x$1" == "xlist" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) go 6 nmcli device wifi list                  ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xstatus" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) echo -n "wifi:         "; go 14 nmcli radio wifi
        echo -n "connectivity: "; go 15 nmcli networking connectivity
        echo -n "connection:   "
        go 16 ''${CMD[nmcli]} device status | grep --word-regexp wifi \
                                   | ''${CMD[grep]} --invert-match wifi-p2p
        ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xmore-status" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) go 12 nmcli connection show --active | grep --word-regexp wifi
        go 16 nmcli device status | grep --word-regexp wifi \
                                   | ''${CMD[grep]} --invert-match wifi-p2p
        go 14 nmcli radio wifi
        go 15 nmcli networking connectivity
        go 13 nmcli | perl -000 -nE 'print if /^w/'
        ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xconnections" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) go 5 nmcli connection show | grep --word-regexp wifi ;;
    * ) die 2 "too many arguments for command '$cmd'"          ;;
  esac
elif [ "x$1" == "xon" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) go 11 nmcli radio wifi on                    ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xoff" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) go 5 nmcli radio wifi off                     ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [[ $1 == connect ]]; then
  case $# in
    0 ) die 2 "command '$1' needs a wifi SSID" ;;
    * ) connect "$password" "''${@:2}"         ;;
  esac
elif [ "x$1" == "xdelete" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) die 2 "command '$cmd' needs a wifi SSID"      ;;
    1 ) go 8 nmcli connection delete "$1"             ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xdown" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) die 2 "command '$cmd' needs a wifi SSID"      ;;
    1 ) go 9 nmcli connection down "$1"               ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [[ $1 == up ]]; then
  cmd="$1"
  shift

  case $# in
    0 ) die 2 "command '$cmd' needs a wifi SSID"                 ;;
    1 ) go 5 nmcli radio wifi on; go 10 nmcli connection up "$1" ;;
    * ) die 2 "too many arguments for command '$cmd'"            ;;
  esac
elif [[ $1 == setup ]]; then
  case $# in
    3 ) setup "$2" "$3" "$password" $ethernet $no_up ;;
    * ) die 2 "usage: $1 SSID IPv4-ADDR"             ;;
  esac
else
  die 2 "command '$1' not recognized (use --help for help)"
fi
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
