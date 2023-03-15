{ config, pkgs, ... }:

{
  users.groups.mythtv.gid = 2000;

  users.users.mythtv = {
    name        = "mythtv";
    group       = "mythtv";
    extraGroups = [
      "disk" "audio" "video" "systemd-journal"
    ];
    createHome  = false;
    uid         = 2000;
#    home        = "${pkgs.mythtv-user}/share/mythtv-user";
    home        = "/home/mythtv";
    shell       = "/run/current-system/sw/bin/bash";
    isSystemUser = true;
  };

  users.groups.mythtv.members = [ "martyn" ];
}
