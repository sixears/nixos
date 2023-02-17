{ pkgs, ... }:

let
  disthttpd = pkgs.writers.writeBash "disthttpd" ''
    set -eu -o pipefail
    ${pkgs.coreutils}/bin/mkdir --mode=0755 --parents /var/run/disthttpd
    ${pkgs.coreutils}/bin/chown nobody: /var/run/disthttpd
    ${pkgs.thttpd}/bin/thttpd -D -p 8888 -r -d /home/martyn/src/dists -l /var/run/disthttpd/thttpd.log -i /var/run/disthttpd/thttpd.pid
  '';
in
  {
    environment.systemPackages = with pkgs; [ thttpd ];

    systemd.services.disthttpd = {
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = disthttpd;
      };
    };
  }
