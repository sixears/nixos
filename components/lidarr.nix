{ pkgs, ... }:

let
  dataDir = "/Deluge/lidarr";
in
  {
    services.lidarr = {
      enable  = true;
      group   = "media";
      dataDir = dataDir;
    };

    networking.firewall.allowedTCPPorts = [ 8686 ];

    services.fcron.systab =
      "@runas(root) 60s ${pkgs.coreutils}/bin/chmod -R g+rwX ${dataDir}";
  }
