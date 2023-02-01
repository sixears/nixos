{ config, pkgs, ... }:

let
  user     = "martyn";
  home     = "/home/${user}";
  hostname = "${pkgs.inetutils}/bin/hostname";
  touch    = "${pkgs.coreutils}/bin/touch";
in
  {
    users.groups.martyn.gid = 1000;

    users.users.martyn = {
      isNormalUser = true;
      name        = user;
      group       = user;
      extraGroups = [
        "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal"
        "users" "scanner" "ftp" "adbusers" "cdrom" "dialout" "input"
      ];
      createHome  = true;
      uid         = 1000;
      home        = home;
      shell       = "/run/current-system/sw/bin/bash";

      # needed for podman; see https://beb.ninja/post/installing-podman/
      # see https://stackoverflow.com/questions/58443334/why-does-podman-report-not-enough-ids-available-in-namespace-with-different-ui
      # if you see 'there might not be enough IDs available in the namespace',
      # try running `podman system migrate`
      subUidRanges = [ { startUid = 100001; count = 65534; } ];
      subGidRanges = [ { startGid = 100001; count = 65534; } ];
      # this stuff appears in /etc/profiles/per-user/$USER
      packages = [
        (let
           rsync       = "${pkgs.rsync}/bin/rsync";
           passwd-file = "/home/martyn/.rsync.secret";
         in
           pkgs.writers.writeBashBin "rsync-deluge" ''
             builtin exec ${rsync} --archive                       \
                                   --password-file ${passwd-file}  \
                                   --port 7798                     \
                                   deluge::deluge/complete/        \
                                   /Deluge/complete/ "$@"
           '')
      ];
    };

    services.fcron.systab =
      "@runas(${user}) 60s ${touch} ${home}/.touch-$(${hostname} -s)";
  }
