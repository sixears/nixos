{ pkgs }: pkgs.writers.writeBashBin "acpi-wakeup-manager" ''
# explicitly enable/disable values in /proc/acpi/wakeup
# by toggling as required

set -u -o pipefail
PATH=/dev/null

wakeup=/proc/acpi/wakeup

# keys in this map are devices; the value is true=>enable,
# false=>disable.  Any devices not mentioned are ignored.
declare -A device_stati=( [XHCI]=false )

mapfile -t lines < $wakeup

for line in "${lines[@]}"; do
  IFS=$'\t'
  read device s_state status <<<"$line"
  [[ -v device_stati[$device] ]] && echo "$device: $status"
  [[ $status =~ enabled ]] && echo "$device"
done
''

# Local Variables:
# mode: sh
# End:
