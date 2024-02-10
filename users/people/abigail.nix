{ config, pkgs, ... }:

let
  user     = "abigail";
  home     = "/home/${user}";
  hostname = "${pkgs.inetutils}/bin/hostname";
  touch    = "${pkgs.coreutils}/bin/touch";
in
  {
    users.groups.abigail.gid = 1002;

    users.users.abigail = {
      name        = user;
      group       = user;
      extraGroups = [
        "disk" "audio" "video" "networkmanager" "scanner" "systemd-journal"
        "users"
      ];
      createHome  = true;
      uid         = 1002;
      home        = "/home/abigail";
      shell       = "/run/current-system/sw/bin/bash";
      isNormalUser = true;
    };

    services.fcron.systab =
      "@runas(${user}) 60s ${touch} ${home}/.touch-$(${hostname} -s)";
  }
