{ bash-header, pkgs }: pkgs.writers.writeBashBin "mkopenvpnconf" ''

set -u -o pipefail -o noclobber; shopt -s nullglob
PATH=/dev/null

source ${bash-header}

Cmd[grep]=${pkgs.gnugrep}/bin/grep

# -- main ----------------------------------------------------------------------

main () {
  local input="$1" output="$2" credfn="$3" autostart="''${4:-}"

  local base
  base="$(gocmdnodryrun 10 basename "$input" .ovpn)"; check_ basename
  local lower0="''${base,,?}"
  local lower="''${lower0// /_}"

  # we don't insist that the credfn exists; it would be valid to create it after
  # running this (or to run this as a user that cannot see the path).
  credfn="$(gocmdnodryrun 14 realpath "$credfn")"; check_ realpath
  output="$(gocmdnodryrun 13 realpath "$output")"; check_ realpath

  local auto
  if [[ $autostart == $lower ]]; then
    auto=true
  else
    auto=false
  fi

  local credline="auth-user-pass $credfn"
  local grepargs=(--fixed-strings --invert-match auth-user-pass "'$input'")
  gocmdeval 11 grep "''${grepargs[@]}" '>'  "'$output'"
  goeval    12 echo "'$credline'"      '>>' "'$output'"

  go 13 echo "$(''${Cmd[cat]} << EOF
    $lower = {
      autoStart = $auto;
      config    = "config $output";
    };
EOF
)"

}

# -- cli -----------------------------------------------------------------------

Usage="$(''${Cmd[cat]} << EOF

usage: $Progname INPUT OUTPUT CREDFN [AUTOSTART]

Munge an openvpn configuration file, output a nix stanza.

Read an openvpn configuration file (typically a .ovpn) to add an auth-user-pass
line to it; output a nix snippet to point to the output conf.

Arguments:
  INPUT     ) The configuration file to munge (e.g., foo.ovpn)
  OUTPUT    ) Where to write the output conf file (e.g., /root/openvpn/foo.conf).
              Will be realpath'd to ensure that it is absolute.
  CREDFN    ) The file in which to look for credentials; e.g., /root/pia.conf.
              Will be realpath'd to ensure that it is absolute.  This file should
              have two lines, the first being the vpn username, the second being
              the vpn password.
  AUTOSTART ) If provided, this value is lowercased, spaces replaced with
              underscores and compared with the basename of INPUT (with .ovpn
              stripped off); if matched, then configuration is set to autostart.

Standard Options:
  -v | --verbose  Be more garrulous, including showing external commands.
  --dry-run       Make no changes to the so-called real world.
  --help          This help.
EOF
)"

getopt_args=( -o v
              --long verbose,dry-run,help
              -n "$Progname" -- "$@" )
OPTS=$( ''${Cmd[getopt]} "''${getopt_args[@]}" )

[ $? -eq 0 ] || dieusage "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

args=()

while true; do
  case "$1" in
    # don't forget to update $Usage!!

    # hidden option for testing

    -v | --verbose  ) Verbose=$((Verbose+1)) ; shift   ;;
    --help          ) usage                            ;;
    --dry-run       ) DryRun=true            ; shift   ;;
    --              ) shift; args+=( "$@" )  ; break   ;;
    *               ) args+=( "$1" )         ; shift   ;;
  esac
done

main "''${args[@]}"

# -- that's all, folks! --------------------------------------------------------
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:

# ------------------------------------------------------------------------------
