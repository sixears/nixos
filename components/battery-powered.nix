{ pkgs, ... }:

let
  lowbat    = import ../pkgs/lowbat.nix { inherit pkgs; };
  systemctl = "${pkgs.systemd}/bin/systemctl";
  grep      = "${pkgs.gnugrep}/bin/grep";
  lid       = "/proc/acpi/button/lid/LID/state";
  open      = "echo lid open";
  closed    = "echo lid closed";
  lidcheck  = "${grep} -iq closed$ ${lid}";
  logger    = "${pkgs.inetutils}/bin/logger";
  log       = "${logger} -t lidcheck";
in
  {
    imports = [ ./fcron.nix ];

    # see the logs with journalctl -t lidcheck
    services.fcron.systab = ''
      @ 60s ${lowbat}/bin/lowbat
      @ 60s ${lidcheck} && ${closed} && ${systemctl} suspend || ${open} | ${log}
    '';
  }
