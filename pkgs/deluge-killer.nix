{ pkgs, ip-public }: pkgs.writers.writeBashBin "deluge-killer" ''
# kill deluge if the VPN dies

grep=${pkgs.gnugrep}/bin/grep
killall=${pkgs.psmisc}/bin/killall
pgrep=${pkgs.procps}/bin/pgrep
route=${pkgs.nettools}/bin/route
sleep=${pkgs.coreutils}/bin/sleep
true=${pkgs.coreutils}/bin/true

sleeptime="''${1:-0}"

while $true; do
          $pgrep openvpn > /dev/null                                 \
      &&  $route --numeric | $grep ^0.0.0.0 | $grep --silent tun0    \
      &&  ! { ${ip-public}/bin/ip-public $sleeptime | $grep ': 82.69.'; } \
   || { $pgrep deluge && { echo -e "\nVPN IS DOWN - killing deluge"; \
                           $killall --signal TERM --regexp deluge;   \
                           $sleep 5;                                 \
                           $killall --signal KILL --regexp deluge;   \
                         }
      }
  [ $sleeptime -eq 0 ] && break
  $sleep $sleeptime
done
''

# Local Variables:
# mode: sh
# End:
