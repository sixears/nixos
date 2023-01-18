{ pkgs ? import <nixpkgs> {}, bash-header }:

with pkgs;

let
#  src     = ./src;
  mkopenvpnconf  = import ./mkopenvpnconf.nix  { inherit bash-header pkgs; };
  mkopenvpnconfs = import ./mkopenvpnconfs.nix { inherit bash-header
                                                         mkopenvpnconf pkgs;};
in
  mkopenvpnconfs
