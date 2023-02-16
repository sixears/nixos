{ pkgs, ip-public }: pkgs.writers.writeBashBin "delug-killer" ''
# we deliberately mis-spell 'deluge' here       ^^^, so that the killall for
# 'deluge' doesn't kill this script

# kill deluge if the VPN dies

grep=${pkgs.gnugrep}/bin/grep
killall=${pkgs.psmisc}/bin/killall
pgrep=${pkgs.procps}/bin/pgrep
route=${pkgs.nettools}/bin/route
sleep=${pkgs.coreutils}/bin/sleep
true=${pkgs.coreutils}/bin/true

sleeptime="''${1:-0}"

while $true; do
  # EITHER:
  #       openvpn is up, AND
  #   AND the default gateway is going through tun0
  #   AND public ip is neither 82.69.* (zen) or 193.219.* (hey broadband)
          $pgrep openvpn > /dev/null                                       \
      &&  $route --numeric | $grep ^0.0.0.0 | $grep --silent tun0          \
      &&  { ! { ${ip-public}/bin/ip-public $sleeptime | $grep ^82.69.      \
             || ${ip-public}/bin/ip-public $sleeptime | $grep ^193.219.; } \
          } \
   || { set -x ; $pgrep deluge && { echo -e "\nVPN IS DOWN - killing deluge"; \
                           $killall --signal TERM --regexp deluge;   \
                           $sleep 5;                                 \
                           $killall --signal KILL --regexp deluge;   \
                         }
      }
  [[ $sleeptime -eq 0 ]] && break
  $sleep $sleeptime
done
''

# Local Variables:
# mode: sh
# End:
