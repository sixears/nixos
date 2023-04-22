{ pkgs, bash-header, ... }:

let
  user     = "heather";
  home     = "/home/${user}";
  lumix-copy =
    (import ../../pkgs/lumix-copy.nix  { inherit pkgs bash-header; });
in
  {
    services.fcron.systab = ''
      @runas(${user}),erroronlymail 60s ${lumix-copy}/bin/lumix-copy --source ${home}/stalker-Camera --log-file ${home}/.stalker-Camera.log --no-delete
    '';
  }
