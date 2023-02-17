{ config, ... }:

let
  userSyncthing   = import ./syncthing.nix { inherit config; };
  mkUserSyncthing = userSyncthing.mkUserSyncthing;
in
  {
    config.networking.firewall.allowedTCPPorts = [ 8484
                                                   # different listen port for each host, to allow
                                                   # for port-forwarding through blackbox
                                                   # each port is 39000+rightmost IP quad
                                                   # dog
                                                   39007
                                                   # defector
                                                   39017
                                                   # blues
                                                   39090
                                                 ];

    imports = [ ../../components/syncthing.nix ];
    config.systemd.services = mkUserSyncthing "martyn";
  }
