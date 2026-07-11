{ pkgs }: pkgs.writers.writeBashBin "wifi-pw-write" ''

PATH=/dev/null

[[ $# -eq 1 ]] || { echo "usage: $0 <password-file>" >&2; exit 2; }

# Set SSID password from input file
SSID_PASSWORDS_FILE=$1

declare -A ssids=()

while IFS= read -r line; do
  line=''${line%% } # remove trailing whitespace
  if [[ $line =~ ^[[:space:]]*(#.*)?$ ]]; then
    :
  elif [[ $line =~ ^([[:alnum:] _.-]+)[[:space:]]*=[[:space:]]*(.+)[[:space:]]*$ ]]; then
    SSID=''${BASH_REMATCH[1]}
    PASSWORD=''${BASH_REMATCH[2]}
    ssids[$SSID]="$PASSWORD"
  else
    echo "Warning: invalid line: $line" >&2
  fi
done < "$SSID_PASSWORDS_FILE"

# Set passwords for matching connections
while read conn; do
  if [[ -v ssids[$conn] ]]; then
    echo "writing password for '$conn'" >&2
    ${pkgs.networkmanager}/bin/nmcli conn modify "$conn" 802-11-wireless-security.psk "''${ssids[$conn]}"
  fi
done < <(${pkgs.networkmanager}/bin/nmcli --terse --fields NAME connection show)

# that's all, folks! -----------------------------------------------------------
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:

