{ config, lib, pkgs, ... }:

{
  environment.etc.aliases.text = ''
    root: root@sixears.org
  '';

  programs.msmtp =
  {
    enable    = true;
    defaults  = {
      aliases = "/etc/aliases";
      tls     = true;
    };
    extraConfig = ''
      domain sixears.co.uk
      from %U@%H
      # logfile does not work for multiple users; they all need write perm
      # to the log file.  Use syslog instead.
      # logfile /var/log/msmtp.log
      # logfile_time_format %FZ%T
      syslog on
    '';
    accounts.default = {
      host         = "ocean.mxroute.com";
      auth         = true;
      user         = "martyn@sixears.org";
      passwordeval = "cat /var/cred/mxroute-password.txt";
    };
  };
}
