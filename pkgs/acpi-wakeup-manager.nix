{ pkgs }: pkgs.writers.writeBash "acpi-wakeup-manager" ''
# explicitly enable/disable values in /proc/acpi/wakeup
# by toggling as required

# https://wiki.archlinux.org/title/Systemd#systemd-tmpfiles_-_temporary_files
# https://discussion.fedoraproject.org/t/something-is-waking-up-my-laptop/86948/4
# https://www.marcusfolkesson.se/blog/determine-wakeup-cause-with-acpi/

set -eu -o pipefail
PATH=/dev/null

wakeup=/proc/acpi/wakeup

# keys in this map are devices; the value is true=>enable,
# false=>disable.  Any devices not mentioned are ignored.
declare -A device_stati=( [AWAC]=false [XHCI]=false
                          [RP01]=false [RP09]=false [RP10]=false )

mapfile -t lines < $wakeup

for line in "''${lines[@]}"; do
  IFS=$'\t'
  read device s_state status <<<"$line"
  if [[ -v device_stati[$device] ]]; then
    if [[ $status =~ enabled ]] && ! ''${device_stati[$device]}; then
      echo "disabling acpi for $device"
      echo $device >> $wakeup
    elif [[ $status =~ disabled ]] && ''${device_stati[$device]}; then
      echo "enabling acpi for $device"
      echo $device >> $wakeup
    fi
  fi
done
''

# Local Variables:
# mode: sh
# End:
