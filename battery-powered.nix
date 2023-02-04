{ pkgs, ... }:

let
  lowbat = import ./pkgs/lowbat.nix { inherit pkgs; };
in
  {
    imports = [ ./fcron.nix ];

    services.fcron.systab = "@ 60s ${lowbat}/bin/lowbat";
  }
