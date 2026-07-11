{ pkgs, ... }:

let
  wakeup-manager = import ../pkgs/acpi-wakeup-manager.nix { inherit pkgs; };
in
  {
    imports = [ ./fcron.nix ];

    services.fcron.systab = "@ 60s ${wakeup-manager}";
  }
