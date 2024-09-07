{ pkgs, ... }:

let
  suspend = pkgs.writers.writeBashBin "susp" ''
    realpath=${pkgs.coreutils}/bin/realpath
    sudo=/run/wrappers/bin/sudo
    systemctl=${pkgs.systemd}/bin/systemctl

    if [[ $UID == 0 ]]; then
      exec $systemctl suspend
    else
      exec $sudo $($realpath $0)
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
