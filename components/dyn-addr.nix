{ pkgs, bash-header, ... }:

let
  dyn-addr = import ../pkgs/dyn-addr.nix { inherit bash-header pkgs; };
in
  {
    # run every 5 mins
    services.fcron.systab = "@erroronlymail 5 ${dyn-addr}/bin/dyn-addr";
  }
