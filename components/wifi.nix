{ wifiMac, ip4addr }:

{ pkgs, ... }:

let
  nm-dispatch       = import ../pkgs/nm-dispatch.nix          { inherit pkgs; };

  # !!! THIS SHOULD BE ON drifting ONLY
  parmiters         = import ../wifi-conns/parmiters.nix      { inherit pkgs; };

  wifi-pw-write-pkg = import ../pkgs/wifi-pw-write.nix        { inherit pkgs; };
  wifi-pw-write     = "${wifi-pw-write-pkg}/bin/wifi-pw-write";
  wifi-pw-txt       = "/root/wifi-pw.txt";

  nmconnection =
    let src = builtins.readFile ../wifi-conns/Architecture.nmconnection;
    in  pkgs.writeText "Architecture.nmconnection"
          (builtins.replaceStrings [ "$IP4ADDR" ] [ ip4addr ] src);

in
  {
    networking.networkmanager = {
      enable = true;
      # note that this won't effect until wifi is
      # actually connected
      wifi.macAddress = wifiMac;
    };

    environment.etc.nm-dispatch = {
      source = "${nm-dispatch}/bin/nm-dispatch";
      target = "NetworkManager/dispatcher.d/70-wifi-wired-exclusive.sh";
    };

    systemd.services.wifi-pw-write = {
      enable        = true;
      description   = "Write WiFi passwords from ${wifi-pw-txt}";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "NetworkManager.service" ];
      wants         = [ "NetworkManager.service" ];
      serviceConfig = {
        Type            = "oneshot";
        ExecStart       = "${wifi-pw-write} ${wifi-pw-txt}";
        RemainAfterExit = "yes";
        Restart         = "no";
      };
    };

    environment.systemPackages = [
      (import ../pkgs/wifi.nix { inherit pkgs; })
    ];

##     networking.wireless = {
##       enable = true;
##
##       secretsFile = "/root/wireless.conf";
##       extraConfig=''
##         ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel
##         mac_addr=1
##       '';
##       networks = {
## #        echelon = { psk = "abcdefgh"; };
##
## #        Architecture.psk = "foo bar";
##         Architecture = {
##           extraConfig = ''
##             mac_value=${wifiMac}
##           '';
##
##           pskRaw = "ext:passwd_Architecture";
##         };
##       };
##     };

      environment.etc = {
        Architecture = {
          source = nmconnection;
          target = "NetworkManager/system-connections/Architecture.nmconnection";
          mode = "0600";
        };
      };
  }
