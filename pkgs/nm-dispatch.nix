{ pkgs }: pkgs.writers.writeBashBin "nm-dispatch" ''
set -x
export LC_ALL=C

grep=${pkgs.gnugrep}/bin/grep
nmcli=${pkgs.networkmanager}/bin/nmcli

connection_id=/tmp/connection.id

enable_disable_wifi ()
{
  result=$($nmcli dev | $grep "ethernet" | $grep -w "connected")
  if [ -n "$result" ]; then
    $nmcli radio wifi off
  else
    $nmcli radio wifi on
  fi
}

if [ "$2" = "up" ]; then
  echo "ConnectionID: $CONNECTION_ID" >> $connection_id
  enable_disable_wifi
fi

if [ "$2" = "down" ]; then
  echo "WifiDown" >> $connection_id
  enable_disable_wifi
fi
''

# Local Variables:
# mode: sh
# End:
