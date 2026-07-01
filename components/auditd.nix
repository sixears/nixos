{ pkgs, ... }:

{
  # Enable auditd
  security.auditd.enable = true;
  security.audit.enable  = true;
  environment.etc."audit/audit.rules".text = ''
    -a always,exit -F arch=b64 -S execve -k cmd_exec
    -a always,exit -F arch=b32 -S execve -k cmd_exec
  '';

  # Ensure log directory and file
  systemd.tmpfiles.rules = [
    "d /var/log/audit 0755 root adm -"
    "f /var/log/audit/audit.log 0640 root adm -"
    "f /var/log/audit/recent_cmds.log 0640 root adm -"
  ];

  # Service to process audit logs
  systemd.services.post-acct = {
    description = "Process Audit Logs After Command Execution";
    after = [ "auditd.service" ];
    wants = [ "auditd.service" ];
    partOf = [ "auditd.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/bash -c '${pkgs.audit}/bin/ausearch -k cmd_exec --since recent | ${pkgs.gnugrep}/bin/grep argv > /var/log/audit/recent_cmds.log'";
      RemainAfterExit = true;
    };
  };

  # Logrotate for audit logs
  services.logrotate = {
    enable = true;
    config = ''
      /var/log/audit/audit.log {
        size 100M
        rotate 10
        compress
        delaycompress
        missingok
        notifempty
        create 640 root adm
        postrotate
          systemctl restart auditd || true
        endscript
      }
    '';
  };

  # Optional: Install audit tools
  environment.systemPackages = with pkgs; [ audit ];
}
