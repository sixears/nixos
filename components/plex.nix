{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 32400 ];

  imports = [ ./unfree.nix ];

  services.plex.enable       = true;
  services.plex.openFirewall = true;
}
