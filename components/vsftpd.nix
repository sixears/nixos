{ config, lib, pkgs, ... }:

{
  networking.firewall = { allowedTCPPorts      = [ 20 21 ];
                          allowedTCPPortRanges = [ { from = 56250;
                                                     to   = 56260; } ];
#                        connectionTrackingModules = [ "ftp" ];
                        };

  services.vsftpd = {
    enable = true;
#   cannot chroot && write
#    chrootlocalUser = true;
    writeEnable = true;
    localUsers = true;
    userlist = [ "martyn" "cam" ];
    userlistEnable = true;

    extraConfig = "pasv_min_port=56250\npasv_max_port=56260\nlocal_umask=022";
  };
}
