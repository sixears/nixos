{ config, pkgs, ... }:

let
  user     = "jj";
  home     = "/home/${user}";
  hostname = "${pkgs.inetutils}/bin/hostname";
  touch    = "${pkgs.coreutils}/bin/touch";
  uid      = 1004;
in
  {
    users.groups.${user}.gid = uid;

    users.users.${user} = {
      name        = user;
      group       = user;
      extraGroups = [
        "disk" "audio" "video" "networkmanager" "scanner" "systemd-journal"
        "users"
      ];
      createHome  = true;
      uid         = uid;
      home        = home;
      shell       = "/run/current-system/sw/bin/bash";
      isNormalUser = true;
    };

    services.fcron.systab =
      "@runas(${user}) 60s ${touch} ${home}/.touch-$(${hostname} -s)";
  }
