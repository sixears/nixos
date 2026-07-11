{ config, lib, pkgs, ... }:

# go to, e.g., https://developers.hp.com/sites/default/files/hplip-3.24.4-plugin.run
# in firefox; save that to (e.g.,) /tmp/hplip-3.24.4-plugin.run
# and then run nixos-prefetch-url file:///tmp/hplip-3.24.4-plugin.run

{
  imports = [ ./fcron.nix ./unfree.nix ];

  services.printing.enable     = true;
  # for reasons beyond my ken, I still had to directly install the ppd direct
  # from /nix/store/j6sfxs1ab46a915rgbj2ps9wr46cfzj6-hplip-3.19.1/share/cups/model/HP/hp-color_laserjet_mfp_m278-m281-ps.ppd.gz
  services.printing.drivers    = [ pkgs.hplipWithPlugin ];

  services.fcron.systab = "@ 60s ${pkgs.cups}/bin/cupsenable vertigen";

  security.sudo.extraRules =
    [
      { commands = [ { command  = "/run/current-system/sw/bin/cupsenable";
                       options  = [ "NOPASSWD" ]; }
                   ];
        users    = [ "martyn" "abigail" "heather" "xander" "jj" ];
      }
    ];
}
