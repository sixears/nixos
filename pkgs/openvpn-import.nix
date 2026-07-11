# 2025-11-22 - we don't need this, we use sudo systemctl start openvpn-*
{ pkgs, bash-header }: pkgs.writers.writeBashBin "openvpn-import" ''

set -u -o pipefail -o noclobber; shopt -s nullglob
PATH=/dev/null

source ${bash-header}

Cmd[nmcli]=${pkgs.networkmanager}/bin/nmcli
Geometry=1280x1024
Overwrite=false
OutputDir=/tmp

# ------------------------------------------------------------------------------

main() {
  local prefix=$1 overwrite=$2 user=$3 pass=$4 ovpns="''${@:5}"

  local -a conns
  capture_array conns gocmd 10 nmcli --terse --fields NAME connection show

  local -A conn_names
  local c
  for c in "''${conns[@]}"; do
    conn_names[$c]=true
  done

  local ovpn
  local -A ovpn_names names_ovpn
  for ovpn in "''${ovpns[@]}"; do
    name=$(gocmd 12 basename "$ovpn"); check_ basename
    name="''${name%%.*}"
    [[ -n $prefix ]] && name="''${prefix%-}-$name"
    if [[ -v names_ovpn[$name] ]]; then
      die 14 "duplicate name '$name' detected ($ovpn vs. ''${names_ovpn[$name]}"
    fi
    ovpn_names[$ovpn]="$name"
    names_ovpn[$name]="$ovpn"
  done

  for ovpn in "''${!ovpn_names[@]}"; do
    name="''${ovpn_names[$ovpn]}"
    if [[ -v conn_names[$ovpn] ]] && ! $overwrite; then
      die 13 "not overwriting extant conn '$name'"
    fi
  done

  for ovpn in "''${!ovpn_names[@]}"; do
    name="''${ovpn_names[$ovpn]}"
    local out
    out="$(gocmd 11 nmcli conn import type openvpn file "$ovpn")"
    check_ "nmcli import"

    if [[ $out =~ ^Connection\ \'(.*)\'\ \(([-a-z0-9]{36})\) ]]; then
      local imported_name=''${BASH_REMATCH[1]} imported_id=''${BASH_REMATCH[2]}
      if [[ ''${BASH_REMATCH[1]} != "$name" ]]; then
        gocmd 15 nmcli conn modify "$imported_id" connection.id "$name"
      fi
      warn "added connection $imported_name->$name [$imported_id]"
      gocmd 17 nmcli conn modify $imported_id -vpn.data "crl-verify-file"
      gocmd 16 nmcli conn modify $imported_id vpn.user-name "$user"
      gocmd 18 nmcli conn modify $imported_id +vpn.data "connection-type=password-tls,password-flags=2"
#      gocmd 17 nmcli conn modify $imported_id +vpn.secrets "password=$pass"
      ## drop crl-verify
      ## pass passwd-file e.g., nmcli conn up aaf27a1d-b7f6-4c66-828c-388a6bb54165 passwd-file /tmp/pass
      ## ensure no more than one vpn is up
      ## ensure that local route stays local, no outbound traffic if vpn dies (kill gateway?)
      ## remove password readig from this script
      ## apparatus: always up

    else
      die "failed to parse output '$out'"
    fi
  done

  ## add auth_user_pass or user/password
  ## for apparatus(/all?), ensure local traffic is non-tun
  ## ensure all other traffic goes via tun0 if up
  ## check ai chat
  ## prevent multiple vpns
}

# ------------------------------------------------------------------------------

getopt_args=( -o vp:s: --long prefix:,secrets:,verbose,debug,dry-run,help )
OPTS=$( ''${Cmd[getopt]} ''${getopt_args[@]} -n "$Progname" -- "$@" )

[ $? -eq 0 ] || dieusage "options parsing failed (--help for help)"

debug "OPTS: '$OPTS'"
# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

prefix=""
secrets=""

while true; do
  debug "processing arg '$1'"
  case "$1" in
    # don't forget to update $Usage!!
    -p | --prefix     ) prefix="$2"  ; shift 2 ;;
    -s | --secrets    ) secrets="$2" ; shift 2 ;;

    # hidden option for testing

    -v | --verbose  ) Verbose=$((Verbose+1)) ; shift   ;;
    --help          ) usage                            ;;
    --dry-run       ) DryRun=true   ; shift   ;;
    --debug         ) Debug=true             ; shift ;;
    --              ) args+=("''${@:2}")     ; break ;;
    *               ) args+=("$1")           ; shift ;;
  esac
done

Usage="$(''${Cmd[cat]} <<EOF
Usage: $Progname

Re-encode pictures to $Geometry to reduce their (byte) size.

  -p | --prefix     MANDATORY prefix the vpn connection names with this
  -O | --overwrite  Allow overwrite of existing files.
  -s | --secrets    MANDATORY read the secrets from this file.  Must be two
                    lines; user, and password

Standard Options:
  -v | --verbose  Be more garrulous, including showing external commands.
  --dry-run       Make no changes to the so-called real world.
  --help          This help.
 --debug          Output additional developer debugging.
EOF
)"

i=1
for x in "''${args[@]}"; do
  debug "ARG#$i: '$x'"
  i=$((i+1))
done

if [[ -z $prefix ]]; then
  usage
fi

if [[ -z $secrets ]]; then
  usage
else
  if [[ -r $secrets ]]; then
    mapfile -t secretsA < $secrets

    case ''${#secretsA[@]} in
      2 ) user="''${secretsA[0]}" pass="''${secretsA[1]}" ;;
      * ) die 19 "found ''${#secretsA[@]} lines in '$secrets'; expected 2" ;;
    esac
  else
    die 18 "could not read secrets file '$secrets'"
  fi
fi

case ''${#args[@]} in
  0 ) usage               ;;
  * ) for i in "''${args[@]}"; do
        [[ -e $i ]] || die 2 "no such file: '$i'"
      done

      main "$prefix" false "$user" "$pass" "''${args[@]}"
      ;;
esac

# that's all, folks! -----------------------------------------------------------
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
