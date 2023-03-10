{ wifiMac }:

{ pkgs, ... }:

let
  nm-dispatch   = import ../pkgs/nm-dispatch.nix              { inherit pkgs; };
  # !!! THIS SHOULD BE ON drifting ONLY
  parmiters     = import ../wifi-conns/parmiters.nix          { inherit pkgs; };
in
  {
    networking.networkmanager = { enable = true;
                                  # note that this won't effect until wifi is
                                  # actually connected
                                  wifi.macAddress = wifiMac; };

    environment.etc.nm-dispatch = {
      source = "${nm-dispatch}/bin/nm-dispatch";
      target = "NetworkManager/dispatcher.d/70-wifi-wired-exclusive.sh";
    };

    # !!! THIS SHOULD BE FOR drifting ONLY !!!
    services.fcron.systab = "@ 600s ${parmiters}";

    environment.systemPackages = [
      (import ../pkgs/wifi.nix { inherit pkgs; })
    ];
  }
