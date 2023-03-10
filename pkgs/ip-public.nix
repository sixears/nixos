{ pkgs }: pkgs.writers.writeBashBin "ip-public" ''

# see https://www.linuxtrainingacademy.com/determine-public-ip-address-command-line-curl/

date=${pkgs.coreutils}/bin/date
curl=${pkgs.curl}/bin/curl

services=(ifconfig.me
          icanhazip.com
          ipecho.net/plain
          ident.me
#          bot.whatismyipaddress.com
#          https://diagnostic.opendns.com/myip
          http://checkip.amazonaws.com
         )

svcs=("''${services[@]}")

do_one=false
case $# in
  0) : ;;
  1) if [[ '-1' == $1 ]]; then
       do_one=true
     else
       echo "usage: $0 [-1]" 1>&2; exit 2
     fi
     ;;
  *) echo "usage: $0 [-1]" 1>&2; exit 2
esac

for i in "''${svcs[@]}"; do
  # or use wget --quiet --output-document=-
  ip="$($curl --silent "$i")"; rv=$?
  if $do_one && [[ 0 -eq $rv ]] && [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
  then
    echo $ip
    exit 0
  else
    printf '%-40s  %5s: %s\n' "$i" "($rv)" "$($curl --silent "$i")"
  fi
done

if $do_one; then
  echo "no IP found" 1>&2
  exit 3
fi
''

# Local Variables:
# mode: sh
# End:
