{ pkgs }: pkgs.writers.writeBash "parmiters" ''
set -eu

target=/etc/NetworkManager/system-connections/Parmiters.nmconnection

cat >$target <<'END'
  [connection]
  id=Parmiters
  uuid=593e88d9-b143-4386-bdc5-8190dd56b683
  type=wifi
  permissions=

  [wifi]
  mac-address-blacklist=
  mode=infrastructure
  ssid=Parmiters

  [wifi-security]
  key-mgmt=wpa-eap

  [802-1x]
  eap=peap;
  identity=16pearce
  password=Antonym7&
  phase2-auth=mschapv2

  [ipv4]
  dns-search=
  method=auto

  [ipv6]
  addr-gen-mode=stable-privacy
  dns-search=
  method=auto

  [proxy]
END

${pkgs.coreutils}/bin/chmod 0600 $target
''

# Local Variables:
# mode: sh
# End:
