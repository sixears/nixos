{ config, ... }:

let
  port            = 8585;
  userSyncthing   = import ./syncthing.nix { inherit config port; };
  mkUserSyncthing = userSyncthing.mkUserSyncthing;
in
  {
    config.networking.firewall.allowedTCPPorts = [ port
                                                   # different listen port for
                                                   # each host, to allow for
                                                   # port-forwarding through
                                                   # blackbox each port is
                                                   # 38000(heather)+rightmost IP
                                                   # quad

                                                   # night
                                                   38024
                                                 ];

    imports = [ ../../components/syncthing.nix ];
    config.systemd.services = mkUserSyncthing "heather";
  }
