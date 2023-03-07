{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./rsync-server.nix
    ];

  services.rsyncd.settings = {
    nixpkgs = { path = "/nix/var/nixpkgs"; };
  };
}
