{ pkgs, ... }:

let
  passwd-file = "/home/martyn/.rsync-secret";
  rsync-deluge = pkgs.writers.writeBashBin "rsync-deluge" ''
    builtin exec ${pkgs.rsync}/bin/rsync --archive                       \
                                         --password-file ${passwd-file}  \
                                         --port 7798                     \
                                         deluge::deluge/complete/        \
                                         /Deluge/complete/ "$@"
  '';
in
  {
    services.fcron.systab = ''
      # runas has apparently stopped working as of 3.3.0
      # don't run at 4&5AM, as defector should be rebooting then
      &runas(martyn) 0 0-3,6-23 * * * /run/wrappers/bin/sudo -u martyn ${rsync-deluge}/bin/rsync-deluge
  '';
  }
