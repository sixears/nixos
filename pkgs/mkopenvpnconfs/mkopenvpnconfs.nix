{ bash-header, mkopenvpnconf, pkgs }: pkgs.writers.writeBashBin "mkopenvpnconfs" ''
# see https://www.privateinternetaccess.com/blog/private-internet-access-legacy-vpn-network-sunset-announcement-30-september/
# https://www.privateinternetaccess.com/forum/discussion/comment/57817#Comment_57817

set -u -o pipefail -o noclobber; shopt -s nullglob
PATH=/dev/null

source ${bash-header}

Cmd[mkopenvpnconf]=${mkopenvpnconf}/bin/mkopenvpnconf
Cmd[unzip]=${pkgs.unzip}/bin/unzip
Cmd[wget]=${pkgs.wget}/bin/wget

no_clean=false
# see https://www.privateinternetaccess.com/helpdesk/guides/routers/dd-wrt-3/dd-wrt-v40559-openvpn-setup
zipfn=openvpn-strong.zip
zip_url=https://www.privateinternetaccess.com/openvpn/$zipfn

TmpDir="/tmp" # has to be global so mktemp can assign to it

# ------------------------------------------------------------------------------

Usage="$(''${Cmd[cat]} <<EOF

usage: $Progname CREDFN TARGET-DIR OPTION*

Create openvpn configuration for embedding into nixos conf.

CREDFN should be a file owned and readable by root only;
it should have 2 lines, being <user> and <pass>.  Just that.

TARGET-DIR is a non-extant directory into which to write the conf files

options:
  -N | --no-stat-check - don't check for sanity of the credentials file
  -a | --autostart     - autostart this vpn (note:lower-case, underscores)
  --no-clean           - don't clean up temporary directory

Standard Options:
  -v | --verbose  Be more garrulous, including showing external commands.
  --dry-run       Make no changes to the so-called real world.
  --help          This help.
EOF
)"

# -- main ----------------------------------------------------------------------

main () {
  local credfn="$1" target_dir="$2"

  if $stat_check; then
    if [[ ! -e $credfn ]]; then
      die 10 "'$credfn' does not exist"
    fi

    local cred_owner
    cred_owner="$(gocmdnodryrun 22 stat --format=%U $credfn)"; check_ stat

    if [[ root != $cred_owner ]]; then
      die 11 "'$credfn' must be owned by root (not '$cred_owner')"
    fi

    local cred_go_access
    cred_go_access="$(gocmdnodryrun 23 stat --format=%a $credfn | \
                        gocmdnodryrun 24 cut --characters 2-3)"
    check_ "stat | cut"

    if [[ 00 != $cred_go_access ]]; then
      die 12 "'$credfn' must not be accesible beyond root"
    fi
  fi

  if [[ -e "$target_dir" ]]; then
   die_unless_dryrun 13 "not overwriting extant '$target_dir'"
  fi

  target_dir="$(gocmd 26 realpath "$target_dir")"; check_ realpath
  credfn="$(gocmd 27 realpath "$credfn")"; check_ realpath

  mktemp --exit 14 --dir TmpDir
  go 25 cd "$TmpDir"
  gocmd 15 wget "$zip_url"
  gocmd 16 unzip -q "$zipfn"
  gocmd 17 mkdir "$target_dir"

  local date
  date="$(gocmdnodryrun 18 date +%FZ%R:%S)"; check_ date
  go 19 echo "$(''${Cmd[cat]} <<EOF
# created by $Progname on $date
{
  services.openvpn.servers = {
EOF
)"
  local i
  for i in *.ovpn; do
    local j="''${i,,?}"
    local k="''${j// /_}"
    local l="''${k%.ovpn}"
    gocmd 20 mkopenvpnconf "$i" "$target_dir/$l.conf" "$credfn" "$autostart"
  done
  go 21 echo -e '  };\n}'
}

# -- cli -----------------------------------------------------------------------

getopt_args=( -o vNa:
              --long verbose,dry-run,help
              --long noclean,no-clean,no-stat-check,autostart:
              -n "$Progname" -- "$@" )
OPTS=$( ''${Cmd[getopt]} "''${getopt_args[@]}" )

[ $? -eq 0 ] || dieusage "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

stat_check=true
autostart=""

args=()

while true; do
  case "$1" in
    -N | --no-stat-check ) no_stat_check=false ; shift   ;;
    -a | --autostart     ) autostart="$2"      ; shift 2 ;;
    --no-clean           ) no_clean=true       ; shift   ;;
    # don't forget to update $Usage!!

    -v | --verbose  ) Verbose=$((Verbose+1)) ; shift   ;;
    --help          ) usage                            ;;
    --dry-run       ) DryRun=true            ; shift   ;;
    --              ) shift; args+=( "$@" )  ; break   ;;
    *               ) args+=( "$1" )         ; shift   ;;
  esac
done

case "''${#args[@]}" in
  2 ) main "''${args[@]}" ;;
  * ) usage               ;;
esac

# -- that's all, folks! --------------------------------------------------------
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:

# ------------------------------------------------------------------------------
