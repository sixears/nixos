{ config, lib, pkgs, ... }:

let
  sys-info = let src = import ../pkgs/sys-info.nix { inherit pkgs; };
             in  pkgs.writers.writeBashBin "sys-info" src;
in
  {
    security.sudo.extraRules =
      [
        { commands = [ { command  = "${sys-info}/bin/sys-info";
                         options  = [ "NOPASSWD" ]; }
                     ];
          users    = [ "ALL" ];
        }
      ];

    environment.systemPackages = [ sys-info ];
  }
