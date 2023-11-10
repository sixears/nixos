{ config, pkgs, ... }:

{
  users.groups.racereplay.gid = 2002;

  users.users.racereplay = {
    name        = "racereplay";
    group       = "racereplay";
    extraGroups = [
      "disk" "audio" "video" "systemd-journal"
    ];
    createHome  = false;
    uid         = 2002;
    home        = "/home/racereplay";
    shell       = "/run/current-system/sw/bin/bash";
    isSystemUser = true;
  };

  users.groups.racereplay.members = [ "martyn" ];
}
