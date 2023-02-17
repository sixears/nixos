{ config, lib, pkgs, ... }:

let
  hostname    = "${pkgs.inetutils}/bin/hostname";
  date        = "${pkgs.coreutils}/bin/date -u +%FZ%T\\ %A";
  reboot-mail = pkgs.writers.writeBash "reboot-mail" ''
    set -eu -o pipefail
    echo "Subject: [$(${date})] $(${hostname}) booted" | sendmail root@sixears.co.uk --from fcron@sixears.co.uk
  '';
  host-id     = pkgs.writers.writeBash "host-id" ''
    set -eu -o pipefail
    exec >& >(sendmail root@sixears.co.uk --from fcron@sixears.co.uk)
    echo "Subject: $(${pkgs.coreutils}/bin/id --user --name)@$(${pkgs.inetutils}/bin/hostname )"
  '';
in
  {
    services.fcron.enable   = true;

    # setting fcrontab doesn't work, I know not why.
    # so we create fcront.
    # note that we need both setgid & setuid
    security.wrappers.fcront = {
      source = "${pkgs.fcron}/bin/fcrontab";
      owner = "fcron";
      group = "fcron";
      setgid = true;
      setuid = true;
    };

    services.fcron.systab = ''
      !mailfrom(fcron@sixears.co.uk)

      @runas(root) 60s /run/current-system/sw/bin/touch /tmp/touch
      %daily,mailto(root),runas(martyn) * 0 ${host-id}
      &mailto(root),runas(root),runatreboot,runonce(true) * * * * * ${reboot-mail}
    '';
  }
