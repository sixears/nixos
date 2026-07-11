{ config, ... }:

let
  port            = 8686;
  userSyncthing   = import ./syncthing.nix { inherit config port; };
  mkUserSyncthing = userSyncthing.mkUserSyncthing;
in
  {
    config.networking.firewall.allowedTCPPorts = [ port ];

    imports = [ ../../components/syncthing.nix ];
    config.systemd.services = mkUserSyncthing "abigail";
  }
