{ pkgs,... }:

let
  dataDir = "/Deluge/sonarr";
in
  {
    services.sonarr = {
      enable  = true;
      group   = "media";
      dataDir = dataDir;
    };

    networking.firewall.allowedTCPPorts = [ 8989 ];

    services.fcron.systab =
      "@runas(root) 60s ${pkgs.coreutils}/bin/chmod -R g+rwX ${dataDir}";
  }
