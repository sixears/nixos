{ config, ... }:

let
  userSyncthing   = import ./syncthing.nix { inherit config; };
  mkUserSyncthing = userSyncthing.mkUserSyncthing;
in
  {
    config.networking.firewall.allowedTCPPorts = [ 8484
                                                   # different listen port for
                                                   # each host, to allow for
                                                   # port-forwarding through
                                                   # blackbox each port is
                                                   # 39000(martyn)+rightmost IP
                                                   # quad

                                                   # dog (martyn only)
                                                   39007
                                                   # defector (martyn only)
                                                   39017
                                                   # night (everyone)
                                                   39024
                                                 ];

    imports = [ ../../components/syncthing.nix ];
    config.systemd.services = mkUserSyncthing "martyn";
  }
