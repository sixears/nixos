{ pkgs, ... }:

with pkgs.lib;
{
  nixpkgs.config.allowUnfreePredicate =
    import ./unfree-predicate.nix { inherit pkgs; };

  # needed for mythtv 0.31 on nixos-22.05
  nixpkgs.config.permittedInsecurePackages = [ "qtwebkit-5.212.0-alpha4" ];
}
