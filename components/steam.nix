{ pkgs, ... }:


{
  imports = [ ./unfree.nix ]; # steam is "unfree"

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  environment.systemPackages = with pkgs; [
    # introduced in nixos-21.05.2021-06-03
    # https://github.com/NixOS/nixpkgs/issues/124308
    (pkgs.steam.override { extraLibraries = pkgs: [ pkgs.pipewire ]; })
  ];
}
