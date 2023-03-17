{ config, ... }:

let
  userSyncthing   = import ./syncthing.nix { inherit config; };
  mkUserSyncthing = userSyncthing.mkUserSyncthing;
in
  {
    config.networking.firewall.allowedTCPPorts = [ 8787 ];

    imports = [ ../../components/syncthing.nix ];
    config.systemd.services = mkUserSyncthing "xander";
  }
