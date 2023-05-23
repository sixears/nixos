{ pkgs }: pkgs.writers.writeBashBin "trim-to-size" ''
builtin set -u -o pipefail

cbin=${pkgs.coreutils}/bin

basename=$cbin/basename
cut=$cbin/cut
du=$cbin/du
false=$cbin/false
getopt=${pkgs.utillinux}/bin/getopt
find=${pkgs.findutils}/bin/find
head=$cbin/head
ls=$cbin/ls
sort=$cbin/sort
true=$cbin/true
rm=$cbin/rm

progname="$($basename "$0")"
verbose=$false

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
  usage="$(cat <<EOF
usage: $progname <dir> <size-in-mib>

trim directory to requested size by removing files, oldest first

EOF
)"
  die 2 "$usage"
}

die() {
  warn "$2"
  exit $1
}

# ------------------------------------------------------------------------------

OPTS=$( $getopt -o vhl: --long verbose,help,exclude-pat:,log-file: \
                -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

exclude_pats=()
log_file=/dev/tty

while true; do
  case "$1" in
    --exclude-pat   ) exclude_pats+=( "$2" ); shift 2 ;;
    --log-file | -l ) log_file="$2"         ; shift 2 ;;

    -v | --verbose  ) verbose=$true ; shift   ;;
    -h | --help     ) usage                   ;;
    # !!! don't forget to update usage !!!
    -- ) shift; break ;;
    * ) break ;;
  esac
done

[ $# -eq 2 ] || usage

dir="$1"
size="$2"

[ -d "$dir" ] || die 3 "not a dir: '$dir'"
[ -w "$dir" ] || die 4 "not writable: '$dir'"
[[ "$size" =~ ^[0-9]+$ ]] || die 5 "not an integer (in MiB): '$size'"

find_args=()
for f in "''${exclude_pats[@]}"; do
  find_args+=( -name "$f" -o )
done

$rm -f "$log_file"
# it is important that the while loop is the parent while the find is the piped
# find is the child process; the find will almost certainly die of a sigPIPE due
# to the early break from the while when the size falls below the limit; the
# script itself will exit with the exit of the parent process.  Why doesn't
# pipefail cause a non-zero exit?  Because it's not a pipe, it's a redirect!
# (I tested this independently; it's really true).
while read -d $'\0' f; do
  [[ $( $du --summarize --block-size=1MiB "$dir" | $cut --fields 1 ) -lt "$size" ]] && break
  info "removing $dir/$f"
  $rm --verbose "$dir/$f" >> "$log_file" || break
done < <( $find "$dir" -type f \( "''${find_args[@]}" -printf '%C@ %P\0' \) | $sort -nz | $cut -z -d ' ' -f 2- )
''
