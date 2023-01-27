{ pkgs }: pkgs.writers.writeBashBin "bowery-secure-init" ''
set -eu -o pipefail

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

    nmcli connection add "''${base_args[@]}" -- "''${config_args}"
    ;;

  *) echo "usage: $0 <js-username> <js-password>" 1>&2; exit 2 ;;
esac
''

# Local Variables:
# mode: sh
# End:
