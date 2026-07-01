{ pkgs, ... }:

let
  let wakeup-manager = import ../pkgs/acpi-wakeup-manager.nix { inherit pkgs; };
in
  {
    environment.systemPackages = [ wakeup-manager ];
  }
