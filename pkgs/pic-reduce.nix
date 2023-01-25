{ pkgs, bash-header }: pkgs.writers.writeBashBin "pic-reduce" ''

set -u -o pipefail -o noclobber; shopt -s nullglob
PATH=/dev/null

source ${bash-header}

Cmd[convert]=${pkgs.imagemagick}/bin/convert

Geometry=1280x1024
Overwrite=false
OutputDir=/tmp

# ------------------------------------------------------------------------------

reduce() {
  local in="$1"
  local outbase
  capture outbase gocmdnodryrun 11 basename "$in"
  local out="$OutputDir"/"$outbase"
  if ! $Overwrite; then
    [[ -e $out ]] && die 4 "not overwriting $out"
  fi
  echo -n "creating $out... "
  gocmd 10 convert "$in" -geometry $Geometry  /tmp/"$outbase"
  echo done
}

main() {
  if [[ -e $OutputDir ]]; then
    if [[ ! -d $OutputDir ]]; then
      die 5 "Output directory $OutputDir is not a directory!"
    fi
  else
    gocmd 11 mkdir $OutputDir
  fi

  local i
  for i in "$@"; do
    reduce "$i"
  done
}

# ------------------------------------------------------------------------------

getopt_args=( -o vOd: --long overwrite,output-dir:,verbose,debug,dry-run,help )
OPTS=$( ''${Cmd[getopt]} ''${getopt_args[@]} -n "$Progname" -- "$@" )

[ $? -eq 0 ] || dieusage "options parsing failed (--help for help)"

debug "OPTS: '$OPTS'"
# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

while true; do
  debug "processing arg '$1'"
  case "$1" in
    # don't forget to update $Usage!!
    -d | --output-dir ) OutputDir="$2"; shift 2 ;;
    -O | --overwrite  ) Overwrite=true; shift ;;

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
  * ) main "''${args[@]}" ;;
esac

# that's all, folks! -----------------------------------------------------------
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
