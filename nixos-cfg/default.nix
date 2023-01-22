{ pkgs ? import <nixpkgs> {}
, system ? builtins.currentSystem }:

let
  src     = ./..;
in
  with pkgs; derivation {
    name      = "nixos-cfg";
    builder   = "${bash}/bin/bash";
    src       =  src;
    args      =  [ ./builder.sh ];

    inherit coreutils findutils;

    inherit system;
  }
