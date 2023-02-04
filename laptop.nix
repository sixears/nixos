{ pkgs, ... }:

let
  hdmi = import ./pkgs/hdmi.nix { inherit pkgs; };
  wifi = import ./pkgs/wifi.nix { inherit pkgs; };
in
  {
    imports = [
      ./battery-powered.nix
      ./resume-set-backlight.nix
    ];

    environment.systemPackages = with pkgs; [ hdmi wifi ];
  }
