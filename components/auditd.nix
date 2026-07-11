{ pkgs, ... }:

{
  # Enable auditd
  security.auditd.enable = true;
  security.audit.enable  = true;

  environment.etc."audit/auditd.conf".text = ''
    log_file       = /run/audit.log
    log_format     = RAW
    log_group      = adm
    priority_boost = 4
    flush          = INCREMENTAL_ASYNC
    freq           = 50
    num_logs       = 5
    disp_qos       = lossy
    dispatcher     = /sbin
    name_format    = NONE
    max_log_file   = 100
    max_log_file_action = KEEP_LOGS
    space_left     = 75
  '';

  # capture all execve calls
#  environment.etc."audit/audit.rules".text = ''
#    -a always,exit -F arch=b64 -S execve,execveat,fexecve -k cmd_exec
#    -a always,exit -F arch=b32 -S execve,execveat,fexecve -k cmd_exec
#  '';

  security.audit.rules = [
    "-a always,exit -F arch=b64 -S execve,execveat -k cmd_exec"
    "-a always,exit -F arch=b32 -S execve,execveat -k cmd_exec"
  ];

  # Ensure log directory and file
  systemd.tmpfiles.rules = [
    "d /var/log/audit 0755 root adm -"
    "f /var/log/audit/audit.log 0640 root adm -"
    # "f /var/log/audit/recent_cmds.log 0640 root adm -"
  ];

  # Service to process audit logs
##  systemd.services.post-acct = {
##    description = "Process Audit Logs After Command Execution";
##    after = [ "auditd.service" ];
##    wants = [ "auditd.service" ];
##    partOf = [ "auditd.service" ];
##    serviceConfig = {
##      Type = "oneshot";
##      ExecStart = "${pkgs.coreutils}/bin/bash -c '${pkgs.audit}/bin/ausearch -k cmd_exec --since recent | ${pkgs.gnugrep}/bin/grep argv > /var/log/audit/recent_cmds.log'";
##      RemainAfterExit = true;
##    };
##  };

  # Logrotate for audit logs
  services.logrotate = {
    enable = true;
    settings = {
      "/var/log/audit/audit.log" = {
        size = "100M";
        rotate = 10;
        compress = true;
        delaycompress = true;
        missingok = true;
        notifempty = true;
        create = "640 root adm";
        postrotate = "systemctl restart auditd";
      };
    };
  };

  # Optional: Install audit tools
  environment.systemPackages = with pkgs; [ audit ];
}
