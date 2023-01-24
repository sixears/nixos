{ pkgs }: pkgs.writers.writeBashBin "acme-cert" ''
# see https://developer.godaddy.com/keys
# to get API keys for /var/cred/godaddy.acme/

# see https://go-acme.github.io/lego/usage/cli/examples/
# for lego usage

# -u: Treat unset variables and parameters other than the special parameters "@"
#     and "*" as an error when performing parameter expansion.  If expansion is
#     attempted on an unset variable or parameter, the shell prints an error
#     message, and, if not interactive, exits with a non-zero status.

# -o pipefail: If set, the return value of a pipeline is the value of the last
#              (rightmost) command to exit with a non-zero status, or zero if
#              all commands in the pipeline exit successfully.  This option is
#              disabled by default.

set -u -o pipefail
PATH=

# nullglob: If set, bash allows patterns which match no files to expand to a
#           null string, rather than themselves.
# dotglob:  If set, bash includes filenames beginning with a . in the results of
#           pathname expansion.
shopt -s nullglob
shopt -s dotglob

basename=${pkgs.coreutils}/bin/basename
getopt=${pkgs.utillinux}/bin/getopt

cat=${pkgs.coreutils}/bin/cat
chmod=${pkgs.coreutils}/bin/chmod
chown=${pkgs.coreutils}/bin/chown
env=${pkgs.coreutils}/bin/env
grep=${pkgs.gnugrep}/bin/grep
hostname=${pkgs.inetutils}/bin/hostname
id=${pkgs.coreutils}/bin/id
lego=${pkgs.lego}/bin/lego
mkdir=${pkgs.coreutils}/bin/mkdir
sudo=/run/wrappers/bin/sudo

progname="$($basename "$0")"
verbose=false
dry_run=false

store=/var/lib/acme
env_dir=/var/cred/godaddy.acme/
email=root@sixears.co.uk
# godaddy nameservers
resolvers=(ns71.domaincontrol.com ns72.domaincontrol.com)
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
usage: $progname <domain>

Create an SSL certificate for a domain.  Domain should be an fqdn, e.g.,
$($hostname -f). Requires sudo access (or to be run as root).  Certificates will
be stored in $store.  Credentials will be read as environment files from
$env_dir.

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

if [ x"$($id --user)" != x0 ]; then
  exec "$sudo" "$0" "$@"
fi

OPTS=$( $getopt -o vhn --long verbose,dry-run,help \
                -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

while true; do
  case "$1" in
    -v | --verbose  ) verbose=true ; shift   ;;
    -h | --help     ) usage                   ;;
    -n | --dry-run  ) dry_run=true ; shift   ;;
    # !!! don't forget to update usage !!!
    -- ) shift; break ;;
    * ) break ;;
  esac
done

[ $# -eq 1 ]  || usage

domain="$1"

cmd=( $env -i $(for i in "$env_dir"/*; do echo "$($basename "$i")"="$($cat "$i")"; done ) )
cmd+=( $lego --accept-tos --dns godaddy --domains $domain --email $email )
cmd+=( --path $store )
for r in ''${resolvers[@]}; do
  cmd+=( --dns.resolvers $r )
done

cert=$store/certificates/$domain.crt
if [ -e $cert ]; then
   cmd+=( renew --days 60 --reuse-key )
else
   cmd+=( run )
fi

go 3 $mkdir --mode=0750 --parents /var/lib/acme/certificates
go 4 $chown root:nginx /var/lib/acme/certificates
# don't cause an email to say there's nothing done
exec >& >($grep -v ': no renewal.$')
go 5 ''${cmd[@]}
go 4 $chmod 0640 /var/lib/acme/certificates/$domain.*
go 4 $chown root:nginx /var/lib/acme/certificates/$domain.*
''

# Local Variables:
# mode: sh
# End:
