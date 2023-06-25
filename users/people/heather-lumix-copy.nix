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
      @runas(${user}),erroronlymail 60s ${lumix-copy}/bin/lumix-copy --source ${source} --log-file ${log} --no-delete
    '';
  }
