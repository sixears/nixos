{ config, lib, pkgs, system, htinydns, bash-header, ... }:

let
  tinydns-cfg = import ../tinydns-cfg { inherit pkgs system htinydns; };
  tinydns-oom-killer =
    import ../pkgs/tinydns-oom-killer.nix { inherit pkgs bash-header;};
in
  {
    services.tinydns = {
      enable = true;
      data   =
        pkgs.lib.strings.fileContents "${tinydns-cfg}/share/tinydns.data";
      ip     = "127.0.0.1";
    };

    systemd.services.tinydns-oom-killer = {
      wantedBy = [ "multi-user.target" ];
      description = "strace tinydns, restart if it hits ENOMEM ";
      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = "${tinydns-oom-killer}/bin/tinydns-oom-killer";
      };
    };

    services.dnscache = {
      enable = true;
      clientIps = [ "127" "192.168" ];

      domainServers = {
        "@" = [ # "192.168.0.1"    # blackbox.sixears.co.uk
                # cloudflare open, private, free - *.2 with malware protection
                "1.1.1.2"
                "1.0.0.2"

                "91.121.113.58"  # secured1.torguard.org
                "91.121.113.7"   # secured.torguard.org
                "212.23.3.100"   # cache01.dns.zen.net.uk.
                "212.23.6.100"   # cache03.dns.zen.net.uk.
                "8.8.8.8"        # google-public-dns-a.google.com.
                "8.8.4.4"        # google-public-dns-b.google.com.
          ];

        "sixears.co.uk" = [ "127.0.0.1" ];
      };

      forwardOnly = true;
    };

    users.users.dnscache.group = "dnscache";
    users.groups.dnscache = {};

    networking.firewall = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  }
