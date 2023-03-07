{ config, lib, pkgs, ... }:

let
  port = 7798;
  cfg = config.services.rsyncd;
  settingsFormat = pkgs.formats.ini { };
  configFile = settingsFormat.generate "rsyncd.conf" cfg.settings;
  # override cmdline for rsync to specify port; rsync-3.2.3 incorrectly
  # ignores a port= written in the [global] section of the config (it still
  # observes it if written in an unmarked section prior); so we force a
  # --port onto the cmdline
  rsync_cmd = "${pkgs.rsync}/bin/rsync --daemon --no-detach "
            + " --config=${configFile} --port=${toString cfg.port}";
in
  {
    networking.firewall.allowedTCPPorts = [ port ];
    systemd.services.rsync.serviceConfig.ExecStart =pkgs.lib.mkForce rsync_cmd;

    services.rsyncd =
      {
        enable  = true;
        port    = port;
        settings =
          {
            global =
              {
                "uid"          = "%RSYNC_USER_NAME%";
                "gid"          = "*";
                "secrets file" = "/root/rsyncd.secrets";
              };
          };
      };
  }
