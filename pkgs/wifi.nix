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

grep=${pkgs.gnugrep}/bin/grep
nmcli=${pkgs.networkmanager}/bin/nmcli
perl=${pkgs.perl}/bin/perl

# ------------------------------------------------------------------------------

warn () {
  echo -e "$1" 1>&2
}

info () {
  if $verbose; then
    echo -e "$1" 1>&2
  fi
}

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

  connect SSID [--password PASSWORD]
                         - connect to a (new) SSID.  *This won't work for a
                           pre-defined connection (list them with
                           'connections'); use 'up' to bring that up, or delete
                           & re-connect to change a password

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
  exit="$1"; shift
  if $dry_run; then info "(CMD) $*"; else info "CMD> $*"; fi
  $dry_run || eval "$@" || die "$exit" "failed: $*"
}

# ------------------------------------------------------------------------------

OPTS=$( $getopt -o vhnp: --long verbose,dry-run,help,password: \
                -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

password=""

while true; do
  case "$1" in
    -v | --verbose  ) verbose=$true ; shift   ;;
    -h | --help     ) usage                   ;;
    -n | --dry-run  ) dry_run=$true ; shift   ;;
    -p | --password ) password="$2" ; shift 2 ;;
    # !!! don't forget to update usage !!!
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ $# -eq 0 ]; then
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense without a command"
  fi

  if [ "x$($nmcli radio wifi)" != "xenabled" ]; then
    if [ -t 0 ]; then
      die 17 "\033[91mwifi is not enabled; use 'wifi on' to turn it on!\033[0m"
    else
      die 17 "wifi is not enabled; use 'wifi on' to turn it on!"
    fi
  else
    go 3 $nmcli device wifi list
  fi
elif [ "x$1" == "xlist" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) go 6 $nmcli device wifi list                  ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xstatus" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) echo -n "wifi:         "; go 14 $nmcli radio wifi
        echo -n "connectivity: "; go 15 $nmcli networking connectivity
        echo -n "connection:   "
        go 16 $nmcli device status | $grep --word-regexp wifi \
                                   | $grep --invert-match wifi-p2p
        ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xmore-status" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) go 12 $nmcli connection show --active | $grep --word-regexp wifi
        go 16 $nmcli device status | $grep --word-regexp wifi \
                                   | $grep --invert-match wifi-p2p
        go 14 $nmcli radio wifi
        go 15 $nmcli networking connectivity
        go 13 $nmcli | $perl -000 -nE 'print if /^w/'
        ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xconnections" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) go 5 $nmcli connection show | $grep --word-regexp wifi ;;
    * ) die 2 "too many arguments for command '$cmd'"          ;;
  esac
elif [ "x$1" == "xon" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) go 11 $nmcli radio wifi on                    ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xoff" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) go 5 $nmcli radio wifi off                    ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xconnect" ]; then
  cmd="$1"
  shift

  case $# in
    0 ) die 2 "command '$cmd' needs a wifi SSID"             ;;
    * ) if [ "x$password" != "x" ]; then
          go 7 $nmcli device wifi connect "'$@'" password "'$password'"
        else
          go 4 $nmcli device wifi connect "'$@'"
        fi
        ;;
  esac
elif [ "x$1" == "xdelete" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) die 2 "command '$cmd' needs a wifi SSID"      ;;
    1 ) go 8 $nmcli connection delete "'$1'"          ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xdown" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) die 2 "command '$cmd' needs a wifi SSID"      ;;
    1 ) go 9 $nmcli connection down "'$1'"            ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
elif [ "x$1" == "xup" ]; then
  cmd="$1"
  shift
  if [ "x$password" != "x" ]; then
    die 2 "--password|-p makes no sense with command '$cmd'"
  fi

  case $# in
    0 ) die 2 "command '$cmd' needs a wifi SSID"      ;;
    1 ) go 10 $nmcli connection up "'$1'"             ;;
    * ) die 2 "too many arguments for command '$cmd'" ;;
  esac
else
  die 2 "command '$1' not recognized (use --help for help)"
fi
''

# Local Variables:
# mode: sh
# End:
