{ pkgs, ... }:

let
  user     = "heather";
  home     = "/home/${user}";
  hostname = "${pkgs.inetutils}/bin/hostname";
  touch    = "${pkgs.coreutils}/bin/touch";
  uid      = 1001;
  presume =
    pkgs.writers.writeBashBin
      "presume"
      "/run/wrappers/bin/sudo /run/current-system/sw/bin/cupsenable vertigen";
in
  {
    users.groups.${user}.gid = uid;

    users.users.${user} = {
      isNormalUser = true;
      name         = user;
      group        = user;
      uid          = uid;
      extraGroups  = [
        "disk" "audio" "video" "networkmanager" "scanner" "systemd-journal"
        "users"
      ];
      createHome   = true;
      home         = home;
      shell        = "/run/current-system/sw/bin/bash";
      openssh.authorizedKeys.keyFiles = [ ./authorized_keys.${user} ];

      # this stuff appears in /etc/profiles/per-user/$USER
      packages = [ presume ];
    };

    services.fcron.systab = ''
      @runas(${user}) 60s ${touch} ${home}/.touch-$(${hostname} -s)
    '';
  }
