{ pkgs, ... }:

{
  networking.firewall = { allowedTCPPorts = [ 9981 9982 ]; };
  services.tvheadend.enable = true;
}
