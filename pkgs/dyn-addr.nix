{ pkgs ? import <nixpkgs> {}, bash-header }: pkgs.writers.writeBashBin "dyn-addr" ''

# https://dyn.addr.tools/

set -u -o pipefail -o noclobber;
shopt -s nullglob
shopt -s dotglob

source ${bash-header}

Cmd[curl]=${pkgs.curl}/bin/curl
Cmd[cut]=${pkgs.coreutils}/bin/cut
Cmd[dig]=${pkgs.dnsutils}/bin/dig
Cmd[logger]=${pkgs.inetutils}/bin/logger
Cmd[sha224sum]=${pkgs.coreutils}/bin/sha224sum

readonly RUN_DIR=/var/run/dyn-addr
readonly LAST_SUCCESSFUL_RUN=$RUN_DIR/last.successful.run
# number of seconds since the last successful run; before we start moaning
readonly RUN_HYSTERESIS=43200

readonly BASE=dyn.addr.tools
readonly DOMAIN="sixears.co.uk"
readonly EXTERNAL_DNS_SERVER=1.1.1.1 # read listed IP from here

# ------------------------------------------------------------------------------

# Retry a command on a particular exit code, up to a max number of attempts,
# with exponential backoff.
# Invocation:
#   err_retry exit_code attempts sleep_multiplier <command>
# exit_codex: The exit code to retry on.
# attempts: The number of attempts to make.
# sleep_millis: Multiplier for sleep between attempts. Examples:
#     If multiplier is 1000, sleep intervals are 1, 2, 4, 8, 16, etc. seconds.
#     If multiplier is 5000, sleep intervals are 5, 10, 20, 40, 80,etc. seconds.
err_retry() {
  local exit_codex="$1" attempts="$2" sleep_millis="$3" cmd="''${@:4}"
  local IFS=,
  local exit_codes=("$exit_codex")
  local IFS=$' \t\n'
  for attempt in $(gocmdnodryrun 241 seq 1 $attempts); do
    [[ $attempt -gt 1 ]] && warn "Attempt $attempt of $attempts"
    # This weird construction lets us capture return codes under -o errexit/-e

    eval "''${cmd[@]}" && local rc=$? || local rc=$?
    for exit_code in "''${exit_codes[@]}"; do
      if [[ $rc -eq $exit_code ]] && [[ $attempt -le $attempts ]]; then
        local sleep_ms="$((2 ** $attempt * $sleep_millis))"
        # sleep wants seconds, rather than millis
        gocmd 242 sleep "''${sleep_ms:0:-3}.''${sleep_ms: -3}"
      elif [[ $attempt -gt $attempts ]]; then
        local cmdstr="$(showcmd "$@")"
        warn "err_retry failed after $attempt attempts ($cmdstr)"
      else
        return $rc
      fi
    done
  done
}

# like curl, but does a retry if curl fails with one of a few well-known error
# codes
# 6      Could not resolve host. The given remote host could not be resolved.
# 7      Failed to connect to host.
# 28     Operation timeout. The specified time-out period was reached according
#        to the conditions.
# 35     SSL connect error. The SSL handshaking failed.
curly() {
  gonodryrun 10 err_retry 6,7,28,35 10 1000 "''${Cmd[curl]}" --silent "$1";
}

capture_my_ip () {
  local varname="$1"
  local _my_ip
  capture _my_ip curly https://api.ipify.org/

  if [[ ! $_my_ip  =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    if [[ -e $LAST_SUCCESSFUL_RUN ]]; then
      local mtime
      capture mtime gocmdnodryrun 22 stat --format %Y "$LAST_SUCCESSFUL_RUN"
      local now
      capture now gocmdnodryrun 23 date +%s
      if [[ $mtime -gt $(($now - $RUN_HYSTERESIS)) ]]; then
        # we allow for some bad IP lookups, up to RUN_HYSTERESIS ago, before we
        # start sending emails
        exit 0
      fi
    else
      die 18 "Bad IP address from https://api.ipify.org/ '$_my_ip'"
    fi
  fi

  printf -v "$varname" %s "$_my_ip"
}

# --------------------------------------

main() {
  [[ 0 == $EUID ]] || dieusage "run as root"

  [[ -d $RUN_DIR ]] || gocmd 19 mkdir $RUN_DIR

  logdest="local7.info"

  local current_ip
  gonodryrun 18 err_retry 18 10 1000 capture_my_ip current_ip

  local api_secret api_sum
  capture api_secret gocmdnodryrun 11 cat /root/dyn.addr.secret
  # <<< implicitly appends a newline :-(
  api_sum="$(  echo -n "$api_secret"         \
             | gocmdnodryrun 12 sha224sum    \
             | gocmdnodryrun 14 cut -d ' ' -f 1 \
            )"
  local my_name=$api_sum.$BASE.

  local api_base=https://$BASE/
  local listed_ip
  capture listed_ip gocmdnodryrun 13 dig @$EXTERNAL_DNS_SERVER +short "$my_name"

  local now
  capture now gocmdnodryrun 15 date '+%Y-%m-%d %H:%M:%S'
  warn "$now - current IP is $current_ip, listed IP is $listed_ip"

  if [[ $listed_ip != $current_ip ]] && [[ -n $current_ip ]]; then
    echo "IP has changed: updating $my_name"
    gocmd 16 curl --data-urlencode "secret=$api_secret" -d ip=self https://$BASE
    gocmd 17 logger -t "$Progname" -p $logdest \
                    "changed IP of $my_name from $listed_ip to $current_ip"
    # use exit 1 to signal non-standard exit (i.e., current godaddy IP was not
    # up-to-date); in particular, then the fcron job will email
    gocmd 20 touch "$LAST_SUCCESSFUL_RUN"
    exit 1
  else
    gocmd 21 touch "$LAST_SUCCESSFUL_RUN"
  fi
}

# ------------------------------------------------------------------------------

Usage="$(''${Cmd[cat]} <<EOF
usage: $Progname OPTION*

update external listed IP addr to our public IP
This is dynamic DNS, as a script.

options:
 -v | --verbose
 --dry-run
 --help
 --debug
EOF
)"

orig_args=("$@")
getopt_args=( -o v --long verbose,dry-run,help,debug )
OPTS=$( ''${Cmd[getopt]} "''${getopt_args[@]}" -n "$Progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

artist=""
users=()
while true; do
  case "$1" in
    # !!! don't forget to update usage !!!
    -v | --verbose  ) Verbose=$((Verbose+1))   ; shift   ;;
    --help          ) usage                              ;;
    --dry-run       ) DryRun=true              ; shift   ;;
    --debug         ) Debug=true               ; shift ;;
    --              ) args+=("''${@:2}")       ; break ;;
    *               ) args+=("$1")             ; shift ;;
  esac
done

debug "CALLED AS: $(showcmd "$0" "''${orig_args[@]}")"

case ''${#args[@]} in
  0 ) main "''${args[@]}" ;;
  * ) usage
esac
''

# Local Variables:
# mode: sh
# End:
