{ pkgs, bash-header }: pkgs.writers.writeBashBin "stc" ''

# https://docs.syncthing.net/rest/config.html
# curl -k -X GET -H "X-API-Key: pqLXA6TKqGhmYUym4UrdGymtkCyxZHYn" https://night:8585/rest/config/defaults/folder  | jq # '.[].id' | less
# https://docs.syncthing.net/v1.28.0/users/config#config-option-gui.apikey

# syncthing simple CLI

set -u -o pipefail -o noclobber; shopt -s nullglob
PATH=/dev/null

source ${bash-header}

Cmd[curl]=${pkgs.curl}/bin/curl
Cmd[hostname]=${pkgs.nettools}/bin/hostname
Cmd[jq]=${pkgs.jq}/bin/jq
Cmd[xml]=${pkgs.xmlstarlet}/bin/xml

declare -ar CONFIG_FILES=( ''${XDG_STATE_HOME:-$HOME/.local/state}/syncthing/config.xml
                           $HOME/.local/state/syncthing/config.xml
                           ''${XDG_CONFIG_HOME:-$HOME/.config}/syncthing/config.xml
                           $HOME/.config/syncthing/config.xml
                         )

set -e
declare -r HOSTNAME="''${HOSTNAME:-$(''${Cmd[hostname]} --short)}"
declare -r USER="''${USER:-$(''${Cmd[id]} --user --name)}"
set +e

# --------------------------------------
# Globals
# --------------------------------------

declare -i Port=0

# --------------------------------------
# Utility Functions
# --------------------------------------

Usage="$(''${Cmd[cat]} <<USAGE
usage: $Progname OPTION* COMMAND

simple syncthing cli client

Commands:

  api-key          Echo the api-key from the config file
  device [string]  Show the XML for some devices.  If the string is provided, it
                   is used as a selector: only devices whose device-id match the
                   string, or whose name is superstring of the string, are
                   selected.  If no name is provided, just the device being
                   queried is shown.  The special value '*' will show all known
                   devices.
  device-id -p PORT [-h HOST]
                   Show the device id of the given instance
  list-devices -p PORT [-h HOST] [ (--key-file|-k) API-KEY-FILE
                                 | (--api-key|-K) API-KEY ]
                   List the devices known by this instance; deviceID & name
  local-device-id  Show the device id of the local instance
  set-device-name [(-p|--port) PORT]
                   Set the device name to "HOSTNAME (USER)".  Only applicable to
                   a local device.
  set-gui-config   ((--key-file|-k) API-KEY-FILE | (--api-key|-K) API-KEY)
                   (  (-w|--password-hash-file) PASSWORD-HASH-FILE
                    | (-W|--password-hash) PASSWORD-HASH )
                   Fix the xml config for the gui; including setting the api-key
  write-api-key (--key-file|-k) API-KEY-FILE [(--api-key|-K) API-KEY]
                   Write the api-key (by default from the config file) to the
                   given file

USAGE
)"

# -- subroutines ---------------------------------------------------------------

declare ConfigFileName=""
findConfigFile() {
  if [[ -z $ConfigFileName ]]; then
    local config_fn
    for config_fn in "''${CONFIG_FILES[@]}"; do
      if [[ -e $config_fn ]]; then
        ConfigFileName="$config_fn"
        return
      fi
    done

    die 10 "no config file found"
  fi
}

# --------------------------------------

read_config_file_value() {
  local xml_path="$1"
  local -n __value="$2"

  findConfigFile

  local xml_args=( --value-of "$xml_path" )
  __value="$(gocmd 13 xml sel -t "''${xml_args[@]}" -n "$ConfigFileName")"
  check_ "xml sel $xml_path"
}

# --------------------------------------

get_api_key() {
  local api_key_file="$1"
  local -n varname="$2"

  if [[ -n $api_key_file ]]; then
    varname=$(<"$api_key_file")
  else
    findConfigFile
    info "ConfigFileName: '$ConfigFileName'"

    read_config_file_value /configuration/gui/apikey varname
  fi
}

# --------------------------------------

local_port() {
  local -n __port_varname="$1"
  local port
  local address
  read_config_file_value /configuration/gui/address address
  if [[ $address =~ :([0-9]+)$ ]]; then
    __port_varname=''${BASH_REMATCH[1]}
    if [[ -z "''${1:-}" ]]; then
      echo "$__port_varname"
    fi
  else
    die 25 "cannot parse port from address '$address'"
  fi
}

# --------------------------------------

get_port() { if [[ $Port -eq 0 ]]; then local_port Port "$@"; fi; }

# --------------------------------------

read_private_file() {
  local filename="$1"
  local -n __contents="$2"

  # Check if the file exists
  if [[ -e $filename ]]; then
    local perms
    perms=$(gocmd 16 stat --format %a "$filename")
    check_ "stat --format %a '$filename'"

    # Check if permissions are only for owner (e.g., 600 or 700)
    if [[ $perms =~ ^([0-7])([0-7][0-7])$ ]]; then
      if [[ ''${BASH_REMATCH[2]} != 00 ]]; then
        die 18 "api key file '$filename' has g/o perms ($perms)"
      elif [[ ! ''${BASH_REMATCH[1]} =~ ^[467] ]]; then
        die 17 "api key file '$filename' is not readable"
      else
        __contents="$(<"$filename")"
      fi
    else
      die 19 "failed to parse perms '$perms' for api key file '$filename'"
    fi
  else
    die 20 "file '$filename' does not exist"
  fi
}

# --------------------------------------

read_password_hash() {
  local password_hash_file_name="$1"
  local -n __password_hash="$2"

  read_private_file "$password_hash_file_name" __password_hash

  local length=''${#__password_hash}
  if [[ $length -lt 60 ]]; then
    die 21 "password hash is not length 60 (got $length: «''${__password_hash}»)"
  elif [[ ! $__password_hash =~ ^\$2a\$10\$[A-Za-z0-9]{53}$ ]]; then
    die 28 "password hash in wrong format (got '$__password_hash')"
  fi
}

# --------------------------------------

read_api_key_file() {
  local api_key_file="$1"
  local -n __api_key="$2"

  read_private_file "$api_key_file" __api_key

  local length=''${#__api_key}
  if [[ $length -lt 32 ]]; then
    die 21 "api_key is not length 32 (got $length: «''${__api_key}»)"
  elif [[ $length -le 32 ]]; then
    local print_api_key="«''${__api_key}»"
    if [[ $length -gt 35 ]]; then
      print_api_key="«''${__api_key:0:35}...»"
    fi
    die 21 "api_key is not length 32 (got $length: $print_api_key)"
  fi
}

# --------------------------------------

insert_or_update_elem_args() {
  local filename="$1" parent_path="$2" node_name="$3" value="$4" varname="$5"

  local sel_args=(--template --value-of "$parent_path/$node_name" "$filename" )
  local args=()
  if gocmd01nodryrun_ 29 xml sel "''${sel_args[@]}" >/dev/null; then
    # node exists, update it
    args=( --update "$parent_path/$node_name" --value "$value" )
  else
    # node does not exist, add it
    args=(--subnode "$parent_path" --type elem -n "$node_name" --value "$value")
  fi

  local a
  # use printf, because echo swallows a '-n' and if you give it a --, it echoes
  # that!
  for a in "''${args[@]}"; do printf -- "$a\n"; done
}

# --------------------------------------

usage_error() { dieusage "$Progname: ''${FUNCNAME[0]//_/-}: $1"; }

# ----------------------------------------------------------
# main
# ----------------------------------------------------------

set_gui_config() {
  local api_key_file="$1" api_key="$2" password_hash_file="$3"
  local password_hash="$4"
  if [[ -z $api_key ]]; then
    if [[ -z $api_key_file ]]; then
      usage_error 'specify either (--key-file|-k) or (--api-key|-K)'
    else
      read_api_key_file "$api_key_file" api_key
    fi
  else
    if [[ -n $api_key_file ]]; then
      usage_error '(--key-file|-k) && (--api-key|-K) are mutually exclusive'
    fi
  fi

  if [[ -n $password_hash_file ]]; then
    if [[ -n $password_hash ]]; then
      usage_error '--password-hash-file and --password-hash are mutually exclusive'
    else
      read_password_hash "$password_hash_file" password_hash
    fi
  else
    if [[ -z $password_hash ]]; then
      usage_error '--password-hash-file or --password-hash are required'
    fi
  fi

  findConfigFile
  info "ConfigFileName: '$ConfigFileName'"

  local -A xml_edits=( [/configuration/gui/@enabled]=true
                       [/configuration/gui/@tls]=true
                       [/configuration/gui/@debugging]=false
                       [/configuration/gui/apikey]="$api_key"
                       [/configuration/gui/theme]="black"
                     )

  if [[ $Port -ne 0 ]]; then
    xml_edits[/configuration/gui/address]=":$Port"
  fi

  local -a xml_ed_args=()
  local k
  for k in "''${!xml_edits[@]}"; do
    xml_ed_args+=( -u $k -v "''${xml_edits[$k]}" )
  done

  local iou_args
  capture_array iou_args \
    insert_or_update_elem_args "$ConfigFileName" /configuration/gui password \
                               "$password_hash" xml_ed_args
  xml_ed_args+=( "''${iou_args[@]}" )

  capture_array iou_args \
    insert_or_update_elem_args "$ConfigFileName" /configuration/gui user \
                               "thyncsing" xml_ed_args
  xml_ed_args+=( "''${iou_args[@]}" )

  local xml_global_args=()
  gocmd 12 cp "$ConfigFileName" "$ConfigFileName.$EPOCHSECONDS"
  $DryRun || xml_global_args+=( --inplace )

  local xml_args=(ed "''${xml_global_args[@]}" -P # -P => preserve whitespace
                  "''${xml_ed_args[@]}" "$ConfigFileName")
  gocmdnodryrun 11 xml "''${xml_args[@]}"
}

# --------------------------------------

list_devices() {
  local api_key_file="$1" api_key="$2" host="$3" port="$4"

  if [[ -n $api_key_file ]] && [[ -n $api_key ]]; then
    usage_error '--api-key && --key-file are mutually exclusive'
  elif [[ $Port -eq 0 ]]; then
    usage_error '--port|-p is required'
  fi

  [[ -n $api_key ]] || get_api_key "$api_key_file" api_key

  local rest_path=rest/config/devices
  local url="https://''${host:-localhost}:$Port/$rest_path"
  local curl_args=( --insecure --request GET --header "X-API-Key: $api_key"
                    "$url" )
  local jq_args=( --raw-output '.[]|"\(.deviceID)\t\(.name)"' )
  gocmd 14 curl "''${curl_args[@]}" | gocmd 15 jq "''${jq_args[@]}"
}

# --------------------------------------

show_devices() {
  local api_key_file="$1" api_key="$2" host="$3" port="$4" device_id="$5"

  if [[ -n $api_key_file ]] && [[ -n $api_key ]]; then
    usage_error '--api-key && --key-file are mutually exclusive'
  elif [[ $Port -eq 0 ]]; then
    usage_error '--port|-p is required'
  fi

  [[ -n $device_id ]] || device_id "$host" "$Port" device_id
  [[ $device_id == '*' ]] && device_id=""

  [[ -n $api_key ]] || get_api_key "$api_key_file" api_key

  local rest_path=rest/config/devices
  local url="https://''${host:-localhost}:$Port/$rest_path"
  local curl_args=( --insecure --request GET --header "X-API-Key: $api_key"
                    "$url" )

  local jq_inner_select='.deviceID == $device_id or (.name | contains($device_id))'
  local jq_select="map(select($jq_inner_select))"
  gocmd 14 curl "''${curl_args[@]}" \
    | gocmd 15 jq --arg device_id "$device_id" "$jq_select"
}

# --------------------------------------

copy_devices() {
  local host_to="$1" port_to="$2" api_key_file="$3" api_key="$4"

  if [[ -z $host_to ]]; then
    usage_error "(-h|--host) is required (even if it's this host's name)"
  fi

  local port_from
  local_port port_from

  local local_api_key
  get_api_key "" local_api_key

  if [[ $port_to -eq 0 ]]; then
    usage_error '--port|-p is required'
  fi

  local remote_api_key
  if [[ -z $api_key ]]; then
    if [[ -z $api_key_file ]]; then
      remote_api_key="$local_api_key"
    else
      get_api_key "$api_key_file" remote_api_key
    fi
  else
    if [[ -n $api_key_file ]]; then
      usage_error '--api-key && --key-file are mutually exclusive'
    else
      remote_api_key="$api_key"
    fi
  fi

  local rest_path=rest/config/devices
  local url="https://localhost:$port_from/$rest_path"
  local curl_args=( --insecure --request GET
                    --header "X-API-Key: $local_api_key"
                    "$url" )

  local devices
  devices="$(gocmd 14 curl "''${curl_args[@]}")"
  check_ "curl ''${curl_args[*]}"

  url="https://''$host_to:$port_to/rest/config/devices"
  curl_args=( --insecure --request PUT --header "X-API-Key: $remote_api_key"
              --header 'Content-Type: application/json'
              --data "$devices"
              "$url"
            )
  gocmd 28 curl "''${curl_args[@]}"
}

# --------------------------------------

write_api_key() {
  local api_key_file="$1" api_key="$2"
  if [[ -z $api_key_file ]]; then
    usage_error '(--key-file|-k) is required'
  else
    gocmd 22 touch "$api_key_file"
    gocmd 23 chmod 0600 "$api_key_file"
    if [[ -z $api_key ]]; then
      get_api_key "" api_key
    fi
    echo "$api_key" >| "$api_key_file"
  fi
}

# --------------------------------------

device_id() {
  local host="$1" port="$2"

  local __local_device_id
  local -n __device_id="''${3:-__local_device_id}"

  local curl_args=( --silent --output /dev/null --head
                    --write-out '%header{X-Syncthing-Id}\n'
                    http://''${host:-localhost}:$Port/rest/noauth/health
                  )
  __device_id="$(gocmd 24 curl "''${curl_args[@]}")"
  check_ "curl ''${curl_args[*]}"
  if [[ $# -lt 3 ]]; then
    echo "$__device_id"
  fi
}

# --------------------------------------

local_device_id() {
  local __device_id
  local __varname="''${1:-__device_id}"
  read_config_file_value /configuration/defaults/folder/device/@id "$__varname"
  [[ -n ''${1:-} ]] || echo "$__varname"
}

# --------------------------------------

set_device_name() {
  # this relies on the local device being the only one in the folder defaults;
  # that doesn't seem reliable

  local host="$1"

  if [[ -n $host ]]; then
    usage_error "--host|-h is not supported (got '$host')"
  fi

  get_port

  local device_id
  local_device_id device_id

  local api_key
  get_api_key "$api_key_file" api_key

  local device_name="$HOSTNAME ($USER)"
  warn "setting device name to '$device_name'"
  rest_path="rest/config/devices/$device_id"
  url="https://''${host:-localhost}:$Port/$rest_path"
  curl_args=( --insecure --request PATCH --header "X-API-Key: $api_key"
              --header 'Content-Type: application/json'
              --data "{\"name\":\"$device_name\"}"
              "$url"
            )
  gocmd 27 curl "''${curl_args[@]}"
}

# ------------------------------------------------------------------------------

orig_args="$@"
getopt_args=( -o vno:p:h:k:K:w:W:
              --long verbose,dry-run,help,debug,port:,host:,key-file:,api-key:
              --long password-hash-file:,password-hash: )
OPTS=$( ''${Cmd[getopt]} ''${getopt_args[@]} -n "$Progname" -- "$@" )

[ $? -eq 0 ] || dieusage "options parsing failed (--help for help)"

debug "OPTS: '$OPTS'"
# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

declare api_key="" api_key_file="" host=""
declare password_hash_file="" password_hash=""


while true; do
  debug "processing arg '$1'"
  case "$1" in
    -p | --port     ) if [[ $2 =~ ^[0-9]+$ ]]; then
                        Port=$2
                      else
                        dieusage "bad port: '$2'"
                      fi
                      shift 2
                      ;;
    -h | --host               ) host="$2"               ; shift 2 ;;
    -k | --key-file           ) api_key_file="$2"       ; shift 2 ;;
    -K | --api-key            ) api_key="$2"            ; shift 2 ;;
    -w | --password-hash-file ) password_hash_file="$2" ; shift 2 ;;
    -W | --password-hash      ) password_hash="$2"      ; shift 2 ;;

    # don't forget to update $Usage!!
    -v | --verbose  ) Verbose=$((Verbose+1)) ; shift   ;;
    --help          ) usage                            ;;
    --dry-run       ) DryRun=true            ; shift   ;;
    --debug         ) Debug=true             ; shift   ;;
    --              ) args+=("''${@:2}")     ; break   ;;
    *               ) args+=("$1")           ; shift   ;;
  esac
done

i=1
for x in "''${args[@]}"; do
  debug "ARG#$i: '$x'"
  i=$((i+1))
done

debug "CALLED AS: $0 $(showcmd "''${orig_args[@]}")"
debug "ARGS: ''${args[*]@Q}"

[[ ''${#args[*]} -eq 0 ]] && usage

check_arg_count() {
  local -A expected
  local exp
  for exp in "$@"; do expected_[$exp]=true; done
  local -i argc=$((''${#args[*]}-1))
  if ''${expected[$argc]:-false}; then
    dieusage "command ''${args[0]} expects $expected args, got $argc (''${args[*]@Q})"
  fi
}

case "''${args[0]}" in
  set-gui-config  ) check_arg_count 0
                    set_gui_config "$api_key_file" "$api_key"                 \
                                   "$password_hash_file" "$password_hash"     ;;
  list-devices    ) check_arg_count 0
                    list_devices "$api_key_file" "$api_key" "$host" "$Port"   ;;
  write-api-key   ) check_arg_count 0
                    write_api_key "$api_key_file" "$api_key"                  ;;
  device-id       ) check_arg_count 0
                    device_id "$host" "$Port"                                 ;;
  device          ) check_arg_count 0 1
                    device_id="''${args[1]:-}"
                    show_devices "$api_key_file" "$api_key" "$host" "$Port"   \
                                 "$device_id"                                 ;;
  local-device-id ) check_arg_count 0
                    local_device_id                                           ;;

  set-device-name ) check_arg_count 0
                    set_device_name "$host"                                   ;;

  api-key         )
    declare api_key
    get_api_key "$api_key_file" api_key
    echo "$api_key"
    ;;

  copy-devices    ) check_arg_count 0
                    get_port
                    copy_devices "$host" "$Port" "$api_key_file" "$api_key"
                    ;;

  *               ) dieusage "unrecognized command ''${args[0]}"              ;;
esac

# that's all, folks! -----------------------------------------------------------
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
