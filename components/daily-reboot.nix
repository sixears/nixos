{ pkgs, ... }:

{
  imports = [ ./fcron.nix ];

  # avoid mirrorfs
  services.fcron.systab =
    let
      cat    = "${pkgs.coreutils}/bin/cat";
      cut    = "${pkgs.coreutils}/bin/cut";
      check-halfday-up =
        "[[ $(${cat} /proc/uptime | ${cut} -d ' ' -f 1 | ${cut} -d . -f 1) -gt 43200 ]]";
      maybe-cmd = name: msg: cmd: pkgs.writers.writeBash name ''
        if ${check-halfday-up}; then
          echo "''${0##*/}: halting..." 1>&2
          ${cmd}
        else
          echo "''${0##*/}: not ${msg} within half-day of booting" 1>&2
          exit 1
        fi
      '';
      halt-maybe = maybe-cmd "halt-maybe" "halting"
                             "${pkgs.systemd}/bin/halt --poweroff";
      boot-maybe = maybe-cmd "boot-maybe" "rebooting"
                             "${pkgs.systemd}/bin/reboot";
    in
      ''
        # All times in GMT

        # timer plug is set to be off 4-445AM.  Halt at 330 for safety.
        # we check for uptime more than ½ day, so as to not immediately shut
        # down on reboot.  In principle, this shouldn't happen - fcron should
        # not run a job at boot that was previously missed, unless bootrun is
        # set - but in practice, I saw this happen.
        # &runas(root) 30 3 * * * ${check-halfday-up} && ${pkgs.systemd}/bin/halt
        &runas(root) 30 3 * * * ${pkgs.systemd}/bin/halt --poweroff
        # this shouldn't run, as the system should be off at 430 per
        # the timer-plug
        # &runas(root) 30 4 * * * ${check-halfday-up} && ${pkgs.systemd}/bin/reboot
        &runas(root) 30 4 * * * ${boot-maybe}
      '';
}
