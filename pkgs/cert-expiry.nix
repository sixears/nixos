{ pkgs }: pkgs.writers.writeBashBin "cert-expiry" ''

# -u: Treat unset variables and parameters other than the special parameters "@"
#     and "*" as an error when performing parameter expansion.  If expansion is
#     attempted on an unset variable or parameter, the shell prints an error
#     message, and, if not interactive, exits with a non-zero status.

# -o pipefail: If set, the return value of a pipeline is the value of the last
#              (rightmost) command to exit with a non-zero status, or zero if
#              all commands in the pipeline exit successfully.  This option is
#              disabled by default.

set -u -o pipefail
# needs to have a non-empty value, some things interpret empty as '.' or worse
PATH=/dev/null

# nullglob: If set, bash allows patterns which match no files to expand to a
#           null string, rather than themselves.
# dotglob:  If set, bash includes filenames beginning with a . in the results of
#           pathname expansion.
shopt -s nullglob
shopt -s dotglob

basename=${pkgs.coreutils}/bin/basename
cat=${pkgs.coreutils}/bin/cat
getopt=${pkgs.utillinux}/bin/getopt

date=${pkgs.coreutils}/bin/date
openssl=${pkgs.openssl}/bin/openssl
sed=${pkgs.gnused}/bin/sed

gracedays=30

progname="$($basename "$0")"
verbose=false
dry_run=false

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
  usage="$($cat <<EOF
USAGE: $progname OPTION* SERVER+

Check for SSL certificate expiry.

EXAMPLES:

  $progname -g 45 /var/lib/acme/certificates/canine.sixears.co.uk.crt

  $progname canine.sixears.co.uk:9001

OPTIONS:
 -g | --gracedays N   Fail if certificate expires within N days.
                      Default: $gracedays.

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
  $dry_run || "$@" || die "$exit" "failed: $*"
}

# ------------------------------------------------------------------------------

OPTS=$( $getopt -o vhng: --long verbose,dry-run,help,gracedays: \
                -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

while true; do
  case "$1" in
    -g | --gracedays ) gracedays="$2"; shift 2 ;;
    # !!! don't forget to update usage !!!
    -v | --verbose  ) verbose=true ; shift   ;;
    -h | --help     ) usage                  ;;
    -n | --dry-run  ) dry_run=true ; shift   ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

[ $# -eq 0 ] && usage

for server in "$@"; do
  openssl_date=( $openssl x509 -noout -enddate )
  sed_date=( $sed -e 's#notAfter=##' )
  if [ x == x"$server" ]; then
    die 2 "empty server name"
  elif [ x/ == "x''${server:0:1}" ]; then
    txt="$(go 3 $cat $server | go 4 "''${openssl_date[@]}" \
                             | go 5 "''${sed_date[@]}" )"
  else
    # initial echo required to ensure openssl connect terminates
    openssl_client=( $openssl s_client -connect "$server" -servername "$server" )
    txt="$(echo | go 6 "''${openssl_client[@]}" 2>/dev/null \
                | go 7 "''${openssl_date[@]}" | go 8 "''${sed_date[@]}")"
  fi

  ssldate="$(go 9 $date -d "$txt" '+%s')"
  nowdate="$(go 10 $date '+%s')"
  diff=$(( $ssldate - $nowdate ))

  if [ $diff -lt $(( $gracedays *24*3600 )) ]; then
    if [ $diff -lt 0 ]; then
      die 1 "Certificate (for) $server has expired."
    else
      expiry=$(( $diff / 3600 / 24 ))
      die 1 "Certificate (for) $server will expire in $expiry days."
    fi
  fi
done
''

# Local Variables:
# mode: sh
# End:
