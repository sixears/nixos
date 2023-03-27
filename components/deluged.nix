{ ... }:

{
  imports = [ ./deluged-local.nix ./rsync-server.nix ];

  networking.firewall = {
    allowedTCPPorts = [ 8112 58846 ];
    extraCommands   = ''
                        ip46tables -A OUTPUT -s 192.168.0.0/24 -m owner --uid-owner 83 -j ACCEPT
                        ip46tables -A OUTPUT -o tun0 -m owner --uid-owner 83 -j ACCEPT
                        ip46tables -A OUTPUT -m owner --uid-owner 83 -j REJECT --reject-with icmp-port-unreachable
                      '';
  };

  services.rsyncd.settings = {
    deluge = { path = "/local/deluge"; "auth users" = "martyn:r"; };
  };

}
