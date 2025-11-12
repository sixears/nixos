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
  local prefix=$1 overwrite=$2 ovpns="''${@:3}"

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
    else
      die "failed to parse output '$out'"
    fi
  done

  ## add auth_pass_file(?) or user/password
}

# ------------------------------------------------------------------------------

getopt_args=( -o vp: --long prefix:,verbose,debug,dry-run,help )
OPTS=$( ''${Cmd[getopt]} ''${getopt_args[@]} -n "$Progname" -- "$@" )

[ $? -eq 0 ] || dieusage "options parsing failed (--help for help)"

debug "OPTS: '$OPTS'"
# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

prefix=""

while true; do
  debug "processing arg '$1'"
  case "$1" in
    # don't forget to update $Usage!!
    -p | --prefix     ) prefix="$2"; shift 2 ;;

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

  -d | --output-dir  Change output directory.  Default: $OutputDir
  -O | --overwrite   Allow overwrite of existing files.

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

case ''${#args[@]} in
  0 ) usage               ;;
  * ) for i in "''${args[@]}"; do
        [[ -e $i ]] || die 2 "no such file: '$i'"
      done

      main "$prefix" false "''${args[@]}"
      ;;
esac

# that's all, folks! -----------------------------------------------------------
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
