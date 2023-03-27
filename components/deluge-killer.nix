{ pkgs, ... }:

let
  ip-public     = import ../pkgs/ip-public.nix { inherit pkgs; };
  deluge-killer = import ../pkgs/delug-killer.nix { inherit pkgs ip-public; };
in
  {
    environment.systemPackages = with pkgs; [ deluge-killer ];

    # we deliberately mis-spell 'deluge' here, so that the killall for 'deluge'
    # doesn't kill the kill service
    systemd.services.delug-killer = {
      wantedBy = [ "multi-user.target" ];
      description = "start the auto-deluge-kill service";
      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = ''${deluge-killer}/bin/delug-killer 1'';
        ExecStop = ''${pkgs.procps}/bin/pkill delug-killer'';
        WorkingDirectory = "/tmp";
      };
    };
  }
