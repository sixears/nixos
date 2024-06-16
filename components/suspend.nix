{ pkgs, ... }:

let
  suspend = pkgs.writers.writeBashBin "susp" ''
    sudo=/run/wrappers/bin/sudo
    systemctl=${pkgs.systemd}/bin/systemctl

    if [[ $UID == 0 ]]; then
      exec $systemctl suspend
    else
      exec $sudo $0
    fi
  '';
in
  {
    security.sudo.extraRules =
      [
        { commands = [ { command  = "${suspend}/bin/susp";
                         options  = [ "NOPASSWD" ]; }
                     ];
          users    = [ "martyn" "abigail" "heather" "xander" "jj" ];
        }
      ];

    environment.systemPackages = [ suspend ];
  }
