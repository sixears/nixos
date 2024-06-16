{ pkgs, ... }:

let
  dataDir = "/Deluge/radarr";
in
  {
    services.radarr = {
      enable  = true;
      group   = "media";
      dataDir = dataDir;
    };

    networking.firewall.allowedTCPPorts = [ 7878 ];

    services.fcron.systab =
      "@runas(root) 60s ${pkgs.coreutils}/bin/chmod -R g+rwX ${dataDir}";
  }
