{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 32400 ];

  imports = [ ./unfree.nix ];

  services.plex.enable       = true;
  services.plex.openFirewall = true;

  services.fcron.systab =
    ''
      30 22 * * sun-thu ${pkgs.procps}/bin/pkill -STOP -f plex
      59 23 * * fri-sat ${pkgs.procps}/bin/pkill -STOP -f plex
      0   7 * * *       ${pkgs.procps}/bin/pkill -CONT -f plex
    '';
}
