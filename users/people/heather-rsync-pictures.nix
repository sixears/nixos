{ pkgs, bash-header, ... }:

let
  user     = "heather";
  top      = "/local/${user}";
  name     = "stalker-Camera";
  source   = "${top}/${name}";
  log      = "${top}/.${name}.log";
  lumix-copy =
    (import ../../pkgs/lumix-copy.nix  { inherit pkgs bash-header; });
in
  {
    services.fcron.systab = ''
      # @runas(heather) 6h for i in /local/heather/Pictures; do ${pkgs.home-backup}/bin/home-backup --source "$i" --target pictures --no-target-slash; done
    '';
  }
