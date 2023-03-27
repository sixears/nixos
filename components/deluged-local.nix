{ lib, pkgs, ... }:

{
  services.deluge = {
    enable = true;
    web.enable = true;
    openFilesLimit = 8192;
    package = pkgs.deluge-2_x;
  };


  # required for deluge to see the journal output from openvpn
  users.users.deluge.extraGroups = [ "systemd-journal" ];
  # https://pychao.com/2021/02/24/difference-between-partof-and-bindsto-in-a-systemd-unit/
  # https://serverfault.com/questions/1012550/systemd-requires-vs-bindsto
#  systemd.services.deluged.serviceConfig.BindsTo = [ "openvpn-us_new_york.service" ];
  systemd.services.deluged.bindsTo = [ "openvpn-us_new_york.service" ];
  systemd.services.deluged.serviceConfig.ExecStartPre=
    [ (lib.concatStrings [ "${pkgs.bash}/bin/bash -c '"
                          "while ! "
                          "${pkgs.systemd}/bin/journalctl --boot --unit openvpn-us_new_york.service"
                          " --since \"$(${pkgs.systemd}/bin/systemctl show openvpn-us_new_york.service --property=ExecMainStartTimestamp"
                          "  | ${pkgs.coreutils}/bin/cut -d = -f 2-)\""
                          "| ${pkgs.gnugrep}/bin/grep -iq \"Initialization Sequence Completed\""
                          "; do echo Waiting for openvpn to come up...; sleep 2s; done"
                          "'"
                         ])
    ];
}
