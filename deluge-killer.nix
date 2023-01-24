{ config, lib, pkgs, ... }:

let
  ip-public     = import ./pkgs/ip-public.nix { inherit pkgs; };
  deluge-killer = import ./pkgs/deluge-killer.nix { inherit pkgs ip-public; };
in
  {
    environment.systemPackages = with pkgs; [ deluge-killer ];

    systemd.services.deluge-killer = {
      wantedBy = [ "multi-user.target" ];
      description = "start the auto-deluge-kill service";
      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = ''${deluge-killer}/bin/deluge-killer 1'';
        ExecStop = ''${pkgs.procps}/bin/pkill deluge-killer'';
        WorkingDirectory = "/tmp";
      };
    };
  }
