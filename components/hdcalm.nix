{ pkgs, ... }:

let
  hdcalm = import ../pkgs/hdcalm.nix { inherit pkgs; };
in
  {
    environment.systemPackages = [ hdcalm ];

    systemd.services.hdcalm = {
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${hdcalm}/bin/hdcalm --enact --verbose";
      };
    };
  }
