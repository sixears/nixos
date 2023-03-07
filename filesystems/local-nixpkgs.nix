{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/nix/var/nixpkgs" = { device = "/local/nixpkgs" ; options = [ "bind" ]; };
  };
}
