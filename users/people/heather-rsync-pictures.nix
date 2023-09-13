{ pkgs, bash-header, ... }:

let
###  user     = "heather";
##  top      = "/local/${user}";
##  name     = "stalker-Camera";
##  source   = "${top}/${name}";
##  log      = "${top}/.${name}.log";
  hosts =
    (import ../../pkgs/hosts.nix  { inherit pkgs; });
  home-backup =
    (import ../../pkgs/home-backup.nix  { inherit pkgs hosts; });
in
  {
    services.fcron.systab = ''
      @runas(heather) 6h ${home-backup}/bin/home-backup --source /local/heather/Pictures --target pictures --no-target-slash
    '';
  }
