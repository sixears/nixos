{ config, lib, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 111 2049 4000 4001 4002 ];
    allowedUDPPorts = [ 111 2049 4000 4001 4002 ];
  };

  services.nfs.server = {
    enable = true;
    statdPort  = 4000;
    lockdPort  = 4001;
    mountdPort = 4002;
  };
}
