{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./rsync-server.nix
    ];

  services.rsyncd.settings = {
    sections = {
      nixpkgs = { path = "/nix/var/nixpkgs"; };
    };
  };
}
