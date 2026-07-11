{ config, ... }:

let
  # we use 8989 because 8888 is the lighttpd service for dev dists
  port            = 8989;
  userSyncthing   = import ./syncthing.nix { inherit config port; };
  mkUserSyncthing = userSyncthing.mkUserSyncthing;
in
  {
    config.networking.firewall.allowedTCPPorts = [ port ];

    imports = [ ../../components/syncthing.nix ];
    config.systemd.services = mkUserSyncthing "jj";
  }
