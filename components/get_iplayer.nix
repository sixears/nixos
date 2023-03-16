{ config, lib, pkgs, ... }:

let
  get_iplayer = import ../pkgs/get_iplayer/default.nix { nixpkgs = pkgs; };
in
  {
#    environment.systemPackages = with pkgs; [ get_iplayer ];
    environment.systemPackages = [ get_iplayer ];
    services.fcron.systab = ''
        # runas has apparently stopped working as of fcron 3.3.0
        &runas(martyn) 0 1 * * * /run/wrappers/bin/sudo -u martyn bash -c 'set -o pipefail; { date; /run/current-system/sw/bin/get_iplayer --pvr; } |& tee /tmp/get_iplayer.log'
      '';
  }
