{ pkgs, ... }:

{
  imports = [ (import ./wifi-conns/bowery-secure-init { inherit pkgs; }) ];
}
