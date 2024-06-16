{ pkgs, ... }:

let
  dataDir = "/Deluge/sabnzbd";
in
  {
    services.sabnzbd = {
      enable = true;
      configFile = "/Deluge/sabnzbd/sabnzbd.ini";
      group = "media";
    };

    networking.firewall.allowedTCPPorts = [ 8080 ];

    services.fcron.systab =
      "@runas(root) 60s ${pkgs.coreutils}/bin/chmod -R g+rwX ${dataDir}";
  }
