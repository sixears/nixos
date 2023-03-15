{ config, lib, pkgs, ... }:

{
  imports =
    [ ../users/system/mythtv.nix
    ];

  environment.systemPackages = with pkgs; [
    mysql mythtv (import ../components/mythtv-convert.nix { inherit pkgs; })
  ];

  networking.firewall.allowedTCPPorts = [ 6544 6547 ];

  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;

  # derived from https://www.mythtv.org/wiki/Systemd_mythbackend_Configuration
  systemd.services.mythbackend = {
    description = "MythTV backend";
    after       = [ "network.target" "NetworkManager-wait-online.service"
                    "mysqld.service" "pingnetwork.service" ];
    wants       = [ "pingnetwork.service" ];
    wantedBy    = [ "multi-user.target" ];
    environment = { HOME= "/home/mythtv"; MYTHCONFDIR="/home/mythtv/.mythtv"; };
    path        = [ pkgs.qt5Full ];

    serviceConfig = {
      Type             = "simple";
      User             = "mythtv";
      StandardOutput   = null;
      KillMode         = "mixed";
      Restart          = "always";
      WorkingDirectory = "~";
      ExecStart        =
        "${pkgs.mythtv}/bin/mythbackend --systemd-journal --loglevel info";
    };
  };

  # https://www.mythtv.org/wiki/Database_Backup_and_Restore#The_Role_of_mythconverg_backup.pl_When_Changing_MythTV_Versions

  services.fcron.systab = ''
    &runas(mythtv) 0 4 * * * ${pkgs.mythtv}/share/mythtv/mythconverg_backup.pl --directory /archive0/mythtv/ --rotate -1
  '';

}
