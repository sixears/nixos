{ config, ... }:

let
  userSyncthing   = import ./syncthing.nix { inherit config; };
  mkUserSyncthing = userSyncthing.mkUserSyncthing;
in
  {
    # we use 8989 because 8888 is the lighttpd service for dev dists
    config.networking.firewall.allowedTCPPorts = [ 8989 ];

    imports = [ ../../components/syncthing.nix ];
    config.systemd.services = mkUserSyncthing "jj";
  }
