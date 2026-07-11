{ pkgs, ... }:

let
  accton  = "${pkgs.acct}/sbin/accton";
  logfile = "/var/log/pacct";
  postrotate = pkgs.writers.writeBash "pacct-postrotate" ''
    set -ex

    exec >& /tmp/pacct-postrotate.log
    /run/current-system/sw/bin/id
    ${accton} off
    ${accton} ${logfile}
  '';
in
  {
    environment.systemPackages = [ pkgs.acct ];
    # ensure that $logfile is created
    systemd.tmpfiles.rules     = [ "f ${logfile} 0640 root adm -" ];

    systemd.services.accton = {
      description = "turn on process accounting";
      after = [ "network.target" ];
      serviceConfig  =  {
        Type            = "oneshot";
        ExecStart       = "${accton} ${logfile}";
        RemainAfterExit = "yes";
        ExecStop        = "${accton} off";
        StandardOutput  = "journal";
        StandardError   = "journal";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Run after logrotate, because hardened logrotate bollockses up the call
    systemd.services.post-logrotate-psacct = {
      description = "restart psacct after logrotations";
      after       = [ "logrotate.service" ];
      wants       = [ "logrotate.service" ];
      partOf       = [ "logrotate.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${postrotate}";
        RemainAfterExit = true;
      };
      wantedBy = [ "logrotate.service" ];
    };

    services.logrotate = {
      enable = true;
      settings = {
        "${logfile}" = {
          compress = true;
          size = "10M";
          rotate = 10;
          delaycompress = true;
          missingok = true;
          notifempty = true;
          create = "640 root adm";
        };
      };
    };
  }
