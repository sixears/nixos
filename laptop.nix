{ pkgs, ... }:

{
  environment.systemPackages =
    [ (import ./wifi-conns/bowery-secure-init.nix { inherit pkgs; }) ];
}
