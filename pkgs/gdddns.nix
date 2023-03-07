{ pkgs ? import <nixpkgs> {}, bash-header }: pkgs.writers.writeBashBin "gdddns" ''

# https://www.instructables.com/Quick-and-Dirty-Dynamic-DNS-Using-GoDaddy/

set -u -o pipefail -o noclobber;
shopt -s nullglob
shopt -s dotglob

source ${bash-header}

Cmd[curl]=${pkgs.curl}/bin/curl
Cmd[jq]=${pkgs.jq}/bin/jq
Cmd[logger]=${pkgs.inetutils}/bin/logger

readonly RUN_DIR=/var/run/gdddns
readonly LAST_SUCCESSFUL_RUN=$RUN_DIR/last.successful.run
# number of seconds since the last successful run; before we start moaning
readonly RUN_HYSTERESIS=43200

readonly DOMAIN="sixears.co.uk"
# readonly HOSTNAME="gateway"
readonly HOSTNAME="@"
readonly FQDN="$HOSTNAME.$DOMAIN"
readonly HOSTDATA_GD_URL="https://api.godaddy.com/v1/domains/$DOMAIN/records/A/$HOSTNAME"

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

  local my_ip api_key api_secret
  gonodryrun 18 err_retry 18 10 1000 capture_my_ip my_ip

  capture api_key    gocmdnodryrun 11 cat /root/godaddy.api.key
  capture api_secret gocmdnodryrun 12 cat /root/godaddy.api.secret
  local -r gdapikey="$api_key:$api_secret"
  local -r curl_auth="Authorization: sso-key $gdapikey"

  local current_gd_ip
  local api_base=https://api.godaddy.com/
  local a_record_url=$api_base/v1/domains/$DOMAIN/records/A/$HOSTNAME
  local a_data_args=( -s -X GET -H "$curl_auth" $HOSTDATA_GD_URL )
  capture gd_a_data gocmdnodryrun 13 curl "''${a_data_args[@]}"
  capture current_gd_ip gocmdnodryrun 14 jq -r '.[0].data' <<< "$gd_a_data"

  local now
  capture now gocmdnodryrun 15 date '+%Y-%m-%d %H:%M:%S'
  warn "$now - Current External IP is $my_ip, GoDaddy DNS IP is $current_gd_ip"

  if [[ $current_gd_ip != $my_ip ]] && [[ -n $my_ip ]]; then
    echo "IP has changed: updating on GoDaddy"
    local -r json_header="Content-Type: application/json"
    local -r put_data="[{\"data\": \"''${my_ip}\"}]"
    gocmd 16 curl -s -X PUT $HOSTDATA_GD_URL -H "$curl_auth" -H "$json_header" \
                  -d "$put_data"
    gocmd 17 logger -t "$Progname" -p $logdest \
                    "Changed IP of $FQDN from $current_gd_ip to $my_ip"
    # use exit 1 to signal non-standard exit (i.e., current godaddy IP was not
    # up-to-date); in particular, then the fcron job
    gocmd 20 touch "$LAST_SUCCESSFUL_RUN"
    exit 1
  else
    gocmd 21 touch "$LAST_SUCCESSFUL_RUN"
  fi
}

# ------------------------------------------------------------------------------

Usage="$(''${Cmd[cat]} <<EOF
usage: $Progname OPTION*

Look up my IP, set our gateway IP at GoDaddy to match.
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
