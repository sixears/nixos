{ config, lib, pkgs, ... }:

let
  dnsmasq_d    = "/etc/dnsmasq.d";
  youtube_conf = dnsmasq_d + "/youtube.conf";
  kill-youtube = pkgs.writers.writeBashBin "kill-youtube" ''
    set -e
    echo 'address=/youtube.com/' > /etc/dnsmasq.d/youtube.conf
    ${pkgs.systemd}/bin/systemctl restart dnsmasq
  '';

  unkill-youtube = pkgs.writers.writeBashBin "unkill-youtube" ''
    set -e
    ${pkgs.coreutils}/bin/rm --force /etc/dnsmasq.d/youtube.conf
    ${pkgs.systemd}/bin/systemctl restart dnsmasq
  '';

 in
  {
    services.dnsmasq = {
      enable = true;
      settings = {
        port = 5353;

        # Never forward plain names (without a dot or domain part)

        # Tells dnsmasq to never forward A or AAAA queries for plain names,
        # without dots or domain parts, to upstream nameservers. If the name is
        # not known from /etc/hosts or DHCP then a "not found" answer is
        # returned.
        domain-needed = true;

        # Never forward addresses in the non-routed address spaces.

        # Bogus private reverse lookups. All reverse lookups for private IP
        # ranges (ie 192.168.x.x, etc) which are not found in /etc/hosts or the
        # DHCP leases file are answered with "no such domain" rather than being
        # forwarded upstream. The set of prefixes affected is the list given in
        # RFC6303, for IPv4 and IPv6.
        bogus-priv = true;

        conf-dir = "${dnsmasq_d}/,*.conf";
      };
      resolveLocalQueries = false;
    };

    environment.etc."dnsmasq.d/dnsmasq.conf" = {
      source = ./dnsmasq.d/dnsmasq.conf;
    };

    services.fcron.systab = ''
      @ 59s ${kill-youtube}/bin/kill-youtube
#      @ 31s ${unkill-youtube}/bin/unkill-youtube
    '';
  }
