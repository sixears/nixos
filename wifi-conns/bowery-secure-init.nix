{ pkgs }: pkgs.writers.writeBashBin "bowery-secure-init" ''
set -eu -o pipefail

grep=${pkgs.gnugrep}/bin/grep
nmcli=${pkgs.networkmanager}/bin/nmcli

if $nmcli | $grep --silent '^bowery-secure '; then
  echo 'bowery-secure connection already exists (per `nmcli conn`)' 1>&2
  exit 4
fi

case $# in
  2) base_args=( type     wifi
                 con-name bowery-secure
                 # ifname   wlp0s20f3
                 ssid     bowery-secure
               )
     config_args=( wifi-sec.key-mgmt  wpa-eap
                   802-1x.eap         peap
                   802-1x.phase2-auth mschapv2
                   802-1x.identity    "$1"
                   802-1x.password "$2"
                 )

     ${pkgs.networkmanager}/bin/nmcli connection add "''${base_args[@]}" \
                                      -- "''${config_args}"
    ;;

  *) echo "usage: $0 <js-username> <js-password>" 1>&2; exit 2 ;;
esac
''

# Local Variables:
# mode: sh
# End:
