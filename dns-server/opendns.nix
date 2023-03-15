{ config, lib, pkgs, system, htinydns, bash-header, ... }:

let
  tinydns-cfg = import ../tinydns-cfg { inherit pkgs system htinydns; };
  tinydns-oom-killer =
    import ../pkgs/tinydns-oom-killer.nix { inherit pkgs bash-header; };
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

    systemd.services.dnscache.requires = [ "tinydns.service" ];

    services.dnscache = {
      enable = true;
      clientIps = [ "127" "192.168" ];

      domainServers = {
        "@" = [ # "192.168.0.1"    # blackbox.sixears.co.uk
                "208.67.220.220" # resolver2.opendns.com
                "208.67.220.222" # resolver4.opendns.com
                "208.67.222.220" # resolver3.opendns.com
                "208.67.222.222" # resolver1.opendns.com
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
