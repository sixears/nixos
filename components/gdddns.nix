{ pkgs, bash-header, ... }:

let
  gdddns = import ../pkgs/gdddns.nix { inherit bash-header pkgs; };
in
  {
    # run once an hour (60mins)
    services.fcron.systab = "@erroronlymail 60 ${gdddns}/bin/gdddns";
  }
