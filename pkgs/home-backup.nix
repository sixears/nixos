{ pkgs, hosts }: pkgs.writers.writeBashBin "home-backup" ''
set -eu -o pipefail

basename=${pkgs.coreutils}/bin/basename
cat=${pkgs.coreutils}/bin/cat
date=${pkgs.coreutils}/bin/date
false=${pkgs.coreutils}/bin/false
flock=${pkgs.utillinux}/bin/flock
getopt=${pkgs.utillinux}/bin/getopt
grep=${pkgs.gnugrep}/bin/grep
hosts=${hosts}/bin/hosts
id=${pkgs.coreutils}/bin/id
ping=/run/wrappers/bin/ping
rsync=${pkgs.rsync}/bin/rsync
rm=${pkgs.coreutils}/bin/rm
stat=${pkgs.coreutils}/bin/stat
tail=${pkgs.coreutils}/bin/tail
touch=${pkgs.coreutils}/bin/touch
true=${pkgs.coreutils}/bin/true

progname="$( $basename "$0" )"
now=$($date +%s)

# ------------------------------------------------------------------------------

warn () { echo -e "$@" 1>&2; }

# don't use && or || here; a negative return will stop the proggie due to -e :-)
info () { if $verbose; then echo -e "$@" 1>&2; fi; }

die () {
  ex=$1; shift
  warn "$*" 1>&2
  exit $ex
}

usage () {
  u="$($cat <<EOF
usage: $progname OPTION [-- EXTRA-RSYNC-ARGS]

Options:
  -u|--user             Set user to use (default: $USER)
  -t|--target           Set rsync target module (default: $USER/)
  -T|--no-target-slash  Don't prepend a '/' to the target
  -s|--source           Set source (default: /home/$USER/)
  -v|--verbose          Increase verbosity; show sub-commands
  -n|--dry-run          Don't run any active commands
  -S|--server           Set backup target server (default: home-backup)
  -R|--resync           Force resync even if we haven't passed the resync threshold

  --help         This usage
EOF
)"
  die 2 "$u"
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

# ------------------------------------------------------------------------------

verbose=$false
dry_run=$false
tmpdir="''${TMPDIR:-/tmp}"
user="''${USER:-"$($id --user --name)"}"
server=home-backup
source=/home/$user/
tgt_suffix=/
resync=$false

OPTS=$( $getopt -o vnu:t:s:S:TR \
                --long verbose,dry-run,help,user:,target:,source:,server:,no-target-slash,resync \
                -n "$progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (try --help)"

eval set -- "$OPTS"

while true; do
  case "$1" in
    -v | --verbose         ) verbose=$true ; shift   ;;
    -n | --dry-run         ) dry_run=$true ; shift   ;;
    -u | --user            ) user="$2"     ; shift 2 ;;
    -t | --target          ) target="$2"   ; shift 2 ;;
    -T | --no-target-slash ) tgt_suffix="" ; shift   ;;
    -s | --source          ) source="$2"   ; shift 2 ;;
    -S | --server          ) server="$2"   ; shift 2 ;;
    -R | --resync          ) resync=$true  ; shift   ;;
    # !!! don't forget to update the usage !!!

    --help         ) usage                 ;;
    --             ) shift; break          ;;
    *              ) break ;;
  esac
done

# [ $# -eq 0 ] || usage

target="''${target:=$user}"
if [ "x$target" != "x$user" ]; then
  lockfn="$tmpdir/$progname-$target".lock
  rsynctouch="$tmpdir/$progname-$target".rsync
  warntouch="$tmpdir/$progname-$target".warn.rsync
  rsync_log="$tmpdir/$progname-$target".rsync.log
else
  lockfn="$tmpdir"/"$progname".lock
  rsynctouch="$tmpdir/$progname".rsync
  warntouch="$tmpdir/$progname".warn.rsync
  rsync_log="$tmpdir/$progname".rsync.log
fi

# keep trying if not recently synced

# https://blog.famzah.net/2013/07/31/using-flock-in-bash-without-invoking-a-subshell/
# http://blog.sam.liddicott.com/2016/02/using-flock-in-bash-without-invoking.html
exec {lock_fd}>"$lockfn"     || exit 255
$flock --nonblock "$lock_fd" || die 254 "ERROR: flock() failed."
echo $$ > "$lockfn"

rsync_period=$(( 6*60*60 )) # rsync no more than every 6 hours
attempt_period=$(( 2*24*60*60 )) # error if no rsync for more than 2 days
rsync_excludes=/home/$user/.rsync-excludes

file_age() {
  fn="$1"
  if [ -e "$fn" ]; then
    echo $(( $now - $($stat --format=%Y "$fn") ))
  else
    echo $now
  fi
}

rsync_age=$(file_age "$rsynctouch")
warn_age=$(file_age "$warntouch")

if $resync || [ $rsync_age -gt $rsync_period ]; then

  if [ -t 0 ]; then out=/dev/tty; else out=/dev/null; fi
  info "CMD> $ping -c 5 $server"
  if $dry_run || $hosts --silent $server && $ping -c 5 $server > $out; then
    cmd=( $rsync --password-file /home/"$user"/.rsync.secret
                 --port 7798
                 --verbose --archive
                 "$source" "$server::''${target%/}''${tgt_suffix}"
                 --exclude .cache/
                 --delete --delete-excluded
        )
    [ -e "$rsync_excludes" ] && cmd+=( --exclude-from "$rsync_excludes" )
    cmd+=("$@")
    $dry_run || $touch "$rsynctouch"
    info "CMD> ''${cmd[@]}"
    if ! $dry_run; then
      if ! "''${cmd[@]}"  >& $rsync_log; then
        x=$?
        warn "$grep --extended-regexp '^(rsync|file)' $rsync_log | tail --lines 50:"
        $grep ^rsync $rsync_log | tail --lines 50 1>&2
        warn ""
        warn "----"
        warn ""
        warn "$tail --lines 50 $rsync_log:"
        $tail --lines 50 $rsync_log 1>&2
        warn ""
        warn "----"
        warn ""
        warn "rsync exited $x"
        exit $x
      fi
    fi
  elif [ $rsync_age -gt $attempt_period ]; then
    msg="no attempted rsync for ''${warn_age}s"
    if [ $warn_age -gt $attempt_period ]; then
      $dry_run || $touch "$warntouch"
      die 253 "$msg"
    else
      [ -t 0 ] && warn "$msg"
    fi
  fi
else
  [ -t 0 ] && warn "not resyncing after only $rsync_age seconds"
fi

# Note that you can skip the “flock -u “$lock_fd” unlock command if it is at the
# very end of your script. In such a case, your lock file will be unlocked once
# your process terminates.
$rm $lockfn
$flock --unlock "$lock_fd"
''

# Local Variables:
# mode: sh
# End:
