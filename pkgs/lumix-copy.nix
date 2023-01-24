{ pkgs, bash-header, ... }: pkgs.writers.writeBashBin "lumix-copy" ''

set -u -o pipefail -o noclobber;
shopt -s nullglob
shopt -s dotglob

source ${bash-header}

Cmd[darktable-cli]=${pkgs.darktable}/bin/darktable-cli
Cmd[exiftool]=${pkgs.exiftool}/bin/exiftool
Cmd[jq]=${pkgs.jq}/bin/jq
Cmd[mount]=/run/wrappers/bin/mount
Cmd[rsync]=${pkgs.rsync}/bin/rsync
Cmd[umount]=/run/wrappers/bin/umount

Dated=true # move to a dated subdirectory
Target=/local/$USER/Pictures
Mount=true
Source=/mnt/sdcard
NoDelete=false # if true, skip the deletion question
LogFile=/dev/null

# ------------------------------------------------------------------------------

main() {
  local -a deletions
  local -A target_dirs=()

  local -a log_lines
  gonodryrun 34 mapfile -t log_lines < "$LogFile"
  local -A logged
  local i
  for i in "''${log_lines[@]}"; do
    logged[$i]=1
  done

  [[ -d $Target ]] || die 26 "No such target dir '$Target'"

  mounts="$(gocmd 11 mount)"
  if $Mount && gocmdnoexitnodryrun grep --quiet " on $Source " <<<"$mounts"
  then
    die 12 "$Source is already mounted"
  fi

  if $Mount; then
    echo "Mounting sdcard: DO NOT REMOVE until told 'OK'"
    gocmd 16 mount "$Source"
  fi

  echo "Copying card contents to ''${Target%/}/..."
  local fn
  while read fn; do
    local bn
    capture bn gocmdnodryrun 19 basename "$fn"

    local target_fn
    local make_dir=""

    if $Dated; then
      local edate date
      capture edate gocmdnodryrun 17 exiftool -dateFormat %04Y/%02m/%02d \
                                              -CreateDate "$fn" -json
      capture date gocmdnodryrun 18 jq --raw-output '.[0].CreateDate' \
                                       --exit-status <<<"$edate"
      check_ "exiftool '$fn' | jq"
      local target_dir="$Target/$date"

      local proto_dirs=("$target_dir"\ *)
      case ''${#proto_dirs[@]} in
        0 ) # stick with the dated dir
            : ;;
        1 ) # one dated dir already found; use that
            target_dir="''${proto_dirs[0]}" ;;
        * ) # too many pre-extant dated dirs to choose from; skip
            warn "Too many dirs match '$target_dir *'; skipping $fn"
            continue
            ;;
      esac

      if    [[ 0 == ''${target_dirs[$target_dir]:-0} ]] \
         && [[ ! -e $target_dir ]]; then
        make_dir="$target_dir"
      fi
      target_fn="$target_dir/$bn"
    else
      target_fn="$Target/$bn"
    fi

    if [[ 1 -eq ''${logged[$bn]:-0} ]]; then
      if [[ -e $target_fn ]]; then

        local source_size target_size
        capture source_size gocmdnodryrun 35 stat --printf %s "$fn"
        capture target_size gocmdnodryrun 36 stat --printf %s "$target_fn"
        if [[ $target_size -eq $source_size ]]; then
          warn "ignoring duplicate '$fn'"
          continue
        fi
      else
        warn "ignoring logged  '$fn'"
        continue
      fi
    fi

    if [[ "" != $make_dir ]]; then
      if $DryRun; then
        gonodryrun 27 echo "(Would create dir $make_dir)"
      else
        gonodryrun 28 echo "Creating $make_dir"
        gocmd 29 mkdir --parents "$target_dir"
      fi
      target_dirs["$target_dir"]=1
    fi

    if [[ ''${fn,,} =~ .rw2$ ]]; then
      ## !!! NOTE:
      ## there is no logged-duplicate-no-repeat protection
      ## for .rw2 files.  It would complicate matters because of the conversion
      ## (we would need to do the conversion, and then check for size)

      target_fn="''${target_fn%.[Rr][Ww]2}.jpg"
      if $DryRun; then
        gonodryrun 30 echo "(Would convert $fn -> $target_fn)"
      else
        gonodryrun 31 echo "Converting $fn -> $target_fn"
        gocmd 32 darktable-cli "$fn" "$target_fn"
      fi
    else
      if $DryRun; then
        gonodryrun 23 echo "(Would copy $fn -> $target_fn)"
      else
        gonodryrun 24 echo "Copying $fn -> $target_fn"
        gocmd 25 cp "$fn" "$target_fn"
      fi
    fi

    $DryRun || gocmdnodryrun 33 basename "$fn" >> "$LogFile"
    deletions+=("$fn")
    # include rw2 files: this is lumix raw format
  done < <( gocmdnodryrun 13 find "$Source" -iname '*.jpg' -o -iname '*.rw2' )

  if ! $NoDelete; then
    while true; do
      local msg
      if $Mount; then
        msg="shall I delete the contents of the sdcard?> "
      else
        msg="shall I delete the contents of $Source?> "
      fi
      local delete=""
      read -p "$msg" delete
      case "''${delete,,}" in
        yes ) echo "Deleting jpgs from ''${Source%/}/..."
              local fn
              for fn in "''${deletions[@]}"; do
                if $DryRun; then
                  gonodryrun 21 echo "(would delete $fn...)"
                else
                  gonodryrun 22 echo "deleting $fn..."
                fi
                gocmd 14 rm -fv "$fn"
              done
              break;;
        no  ) echo "Skipping delete of contents of ''${Source%/}/"
              break;;
        *   ) echo "Please answer 'yes' or 'no' (got '$delete')"
      esac
    done
  fi

  if $Mount; then
    gocmd 15 umount "$Source"
    echo "OK: you may remove the sdcard now"
  fi
}

# ------------------------------------------------------------------------------

Usage="$(''${Cmd[cat]} <<EOF
usage: $Progname OPTION*

copy sdcard contents to $Target

options:
 -s | --source <DIR>  Copy/move files from here; turn off automount behaviour.
 -t | --target <DIR>  Copy/move files to here (in dated subdirectory).
 -C | --copy          Skip the deletion prompt after the copy.
    | --no-delete

 -v | --verbose
 -n | --dry-run
 -h | --help
EOF
)"

orig_args=("$@")
getopt_args=( --options s:t:DvCL:
              --long source:,target:,no-dated,copy,no-delete,log-file:
              --long verbose,dry-run,help,debug )
OPTS=$( ''${Cmd[getopt]} "''${getopt_args[@]}" -n "$Progname" -- "$@" )

[ $? -eq 0 ] || die 2 "options parsing failed (--help for help)"

# copy the values of OPTS (getopt quotes them) into the shell's $@
eval set -- "$OPTS"

while true; do
  case "$1" in
    -v | --verbose  ) Verbose=$((Verbose+1)) ; shift ;;
    --help          ) usage                          ;;
    --dry-run       ) DryRun=true            ; shift ;;
    --debug         ) Debug=true             ; shift ;;

    -s | --source   ) Source="$2"; Mount=false; shift 2 ;;
    -t | --target   ) Target="$2";              shift 2 ;;
    -D | --no-dated ) Dated=false;              shift   ;;
    -C | --copy | --no-delete ) NoDelete=true ; shift   ;;
    -L | --log-file ) LogFile="$2";             shift 2 ;;

    # !!! don't forget to update usage !!!
    --              ) args+=("''${@:2}")       ; break ;;
    *               ) args+=("$1")             ; shift ;;
  esac
done

debug "CALLED AS: $(showcmd "$0" "''${orig_args[@]}")"

case ''${#args[@]} in
  0 ) main  ;;
  * ) usage ;;
esac

''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
