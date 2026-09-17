{ config, pkgs, ... }:

{
  users.groups.plex.gid = 193;

  users.users.plex = {
    name        = "plex";
    group       = "plex";
    extraGroups = [
      "disk" "audio" "video" "systemd-journal"
    ];
    createHome  = false;
    uid         = 193; # to match nixos/modules/services/misc/plex.nix
#    home        = "${pkgs.plex-user}/share/plex-user";
    home        = "/home/plex";
    shell       = "/run/current-system/sw/bin/bash";
    isSystemUser = true;
  };

  users.groups.plex.members = [ "martyn" "xander" ];
}
