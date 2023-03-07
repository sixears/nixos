{ pkgs, ... }:

{
  services.fcron.systab =
    ''
      %daily,runas(martyn),timezone(Europe/London) * 0 ${pkgs.git}/bin/git -C /nix/var/nixpkgs/nixos-22.05-HEAD/ pull
    '';
}
