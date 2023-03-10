{ pkgs ? import <nixpkgs> {}
, system ? builtins.currentSystem
, htinydns
}:

with pkgs; derivation {
  name      = "tinydns-cfg";
  builder   = "${bash}/bin/bash";
  src       =  ../hosts-data;
  args      =  [ ./builder.sh ];

  inherit coreutils findutils htinydns glibcLocales;

  inherit system;
}
