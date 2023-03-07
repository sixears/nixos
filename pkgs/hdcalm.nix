{ pkgs }: pkgs.writers.writeBashBin "hdcalm" ''

set -eu -o pipefail

basename=${pkgs.coreutils}/bin/basename
cut=${pkgs.coreutils}/bin/cut
false=${pkgs.coreutils}/bin/false
getopt=${pkgs.utillinux}/bin/getopt
grep=${pkgs.gnugrep}/bin/grep
hdparm=${pkgs.hdparm}/bin/hdparm
id=${pkgs.coreutils}/bin/id
lsblk=${pkgs.utillinux}/bin/lsblk
perl=${pkgs.perl}/bin/perl
smartctl=${pkgs.smartmontools}/bin/smartctl
sudo=/run/wrappers/bin/sudo
true=${pkgs.coreutils}/bin/true

progname="$( $basename "$0" )"
verbose=$false
enact=$false
dry_run=$false

warn () { echo -e "$@" 1>&2; }

# don't use && or || here; a negative return will stop the proggie due to -e :-)
info () { if $verbose; then echo -e "$@" 1>&2; fi; }

die () {
  ex=$1; shift
  warn "$*" 1>&2
  exit $ex
}

usage () {
  die 2 "usage: $progname [-v] [-x|--enact]"
}

go () {
  info "CMD> $@"
  if ! $dry_run; then
    $@
  fi
}

sudo () {
  if [ "$( $id --user )" -eq 0 ]; then
    go "$@"
  else
    go $sudo "$@"
  fi
}

OPTS=$( $getopt -o vXn --long verbose,enact,dry-run,help -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (try --help)"

eval set -- "$OPTS"

while true; do
  case "$1" in
    -v | --verbose ) verbose=$true ; shift ;;
    -X | --enact   ) enact=$true   ; shift ;;
    -n | --dry-run ) dry_run=$true ; shift ;;

    --help         ) usage                 ;;
    --             ) shift; break          ;;
    *              ) break ;;
  esac
done

[ $# -eq 0 ] || usage

# --nodeps (-d) means no partitions, etc.
# rota == rotating; 1 means yes (HDD), 0 means no (SSD)
for x in $( $lsblk --nodeps --noheadings --output name,rota | $grep 1$ | \
                $grep --invert-match ^mmcblk | $perl -naE "say \$F[0]" ); do
  d=/dev/"$x"
  if $enact; then
    cmd=("$hdparm" -S 60 "$d")
    sudo ''${cmd[@]} || break
  else
    cmd=("$smartctl" --info --nocheck never "$d")
    rot="$(sudo "''${cmd[@]}" | $grep ^Rotation | $cut -c 19-)" || $true
    pow="$(sudo "''${cmd[@]}" | $grep ^Power\ mode | $cut -c 19-)" || $true
    printf '%3s  %-20s  %s\n' "$x" "$rot" "$pow"
  fi
done
''

# Local Variables:
# mode: sh
# End:
