{ config, pkgs, ... }:

{
  users.groups.gitit.gid = 2001;

  users.users.gitit = {
    name        = "gitit";
    group       = "gitit";
    extraGroups = [ "disk" "systemd-journal" ];
    createHome  = true;
    uid         = 2001;
    home        = "/home/gitit";
    shell       = "/run/current-system/sw/bin/bash";
    isSystemUser = true;
  };

  users.groups.gitit.members = [ "martyn" ];
}
