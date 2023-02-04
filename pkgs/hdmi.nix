{ pkgs }: pkgs.writers.writeBashBin "hdmi" ''

# -u: Treat unset variables and parameters other than the special parameters "@"
#     and "*" as an error when performing parameter expansion.  If expansion is
#     attempted on an unset variable or parameter, the shell prints an error
#     message, and, if not interactive, exits with a non-zero status.

# -o pipefail: If set, the return value of a pipeline is the value of the last
#              (rightmost) command to exit with a non-zero status, or zero if
#              all commands in the pipeline exit successfully.  This option is
#              disabled by default.

builtin set -u -o pipefail

# nullglob: If set, bash allows patterns which match no files to expand to a
#           null string, rather than themselves.
# dotglob:  If set, bash includes filenames beginning with a . in the results of
#           pathname expansion.
builtin shopt -s nullglob
builtin shopt -s dotglob

basename=${pkgs.coreutils}/bin/basename
false=${pkgs.coreutils}/bin/false
getopt=${pkgs.utillinux}/bin/getopt
true=${pkgs.coreutils}/bin/true

progname="$($basename "$0")"
verbose=$false
dry_run=$false

cut=${pkgs.coreutils}/bin/cut
head=${pkgs.coreutils}/bin/head
grep=${pkgs.gnugrep}/bin/grep
perl=${pkgs.perl}/bin/perl
sort=${pkgs.coreutils}/bin/sort
xrandr=${pkgs.xorg.xrandr}/bin/xrandr

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
usage: $progname [on|off] OPTION*

control HDMI output

If on/off is not explicitly passed, then hdmi output is turned on if it is
detected.

options:
 -d | --display     [detected] set the HDMI output to use
 -p | --primary     [detected] set the primary display
 -r | --resolution  [detected] set the resolution to use

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

gox() {
  if $dry_run; then info "(XEC) $*"; else info "XEC> $*"; fi
  $dry_run || exec "$@"
}

# ------------------------------------------------------------------------------

OPTS=$( $getopt --options vhnd:p:r:                         \
                --longoptions verbose,dry-run,help          \
                --longoptions display:,primary:,resolution: \
                --name "$progname" -- "$@"                  )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

xrandr_text="''${XRANDR_TEXT:-$($xrandr)}"

resre='\b\d+x\d+[+-]\d+[+-]\d+\b'

primary=$( builtin echo "$xrandr_text" | $grep --word-regexp connected \
                                       | $grep --word-regexp primary   \
                                       | $cut -d ' ' -f 1              \
         )

displays=($( builtin echo "$xrandr_text" | $grep --word-regexp connected \
                                         | $grep --word-regexp           \
                                                 --invert-match primary  \
                                         | $perl -nlE 'say unless /'"$resre"'/' \
                                         | $cut -d ' ' -f 1              \
          ))

disconnects=($( builtin echo "$xrandr_text" | $grep --word-regexp disconnected \
                                            | $perl -lF'/\s+/' -E 'say $F[0] if /'"$resre"'/'
            ))

case ''${#displays[@]} in
  0 ) display=""                                        ;;
  1 ) display=''${displays[0]}                          ;;
  * ) warn "multiple displays found: ''${displays[@]}"
      display=""                                        ;;
esac

noresre="(?!$resre)"
perle='say $F[1] if /\S+ connected '$noresre'(?!primary)/.../^\S/'
resolution=$( builtin echo "$xrandr_text" | $perl -lF'/\s+/' -E "$perle"     \
                                          | $sort --numeric-sort --reverse   \
                                          | $head --lines 1                  \
            )

while true; do
  case "$1" in
    -d | --display    ) display="$2"    ; shift 2 ;;
    -p | --primary    ) primary="$2"    ; shift 2 ;;
    -r | --resolution ) resolution="$2" ; shift 2 ;;

    -v | --verbose  ) verbose=$true ; shift   ;;
    -h | --help     ) usage                   ;;
    -n | --dry-run  ) dry_run=$true ; shift   ;;
    # !!! don't forget to update usage !!!
    -- ) shift; break ;;
    * ) break ;;
  esac
done

case $# in
  0 ) [ -z "$display" ] && mode=off || mode=on ;;
  1 ) mode="$1"; shift                         ;;
  *) usage                                     ;;
esac

info "primary:     '$primary'"
info "display:     '$display'"
if [ ''${#disconnects[@]} -eq 0 ]; then
  info 'no disconnects'
else
  for d in ''${disconnects[@]}; do
    info "disconnect: '$d'"
  done
fi

case "$mode" in
  "on" ) gox xrandr --output "$primary" --primary             \
                    --output "$display" --right-of "$primary" \
                    --mode "$resolution"
         ;;
  "off") if [ ! -z "''${resolution:-}" ]; then
           die 2 "--resolution|-r (''${resolution:-}) is invalid with mode 'off'"
         fi
         if [ -z "$display" ]; then
           if [ ''${#disconnects[@]} -eq 0 ]; then
             die 1 "nothing to do"
           else
             for d in "''${disconnects[@]}"; do
               gox xrandr --output "$d" --off
             done
           fi
         else
           gox xrandr --output "$display" --off
         fi
         ;;
  *    ) usage
         ;;
esac
''
