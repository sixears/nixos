{ pkgs, ... }:

{
  services.unifi = {
    unifiPackage = pkgs.unifi;
    openFirewall = true;
    enable = true;
  };
}
