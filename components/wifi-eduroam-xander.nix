{ pkgs, ... }:

let
  nmconnection =
    let src = builtins.readFile ../wifi-conns/eduroam-xander.nmconnection;
    in  pkgs.writeText "eduroam.nmconnection" src;
in
  {
    environment.etc = {
      eduroam = {
        source = nmconnection;
        target = "NetworkManager/system-connections/eduroam.nmconnection";
        mode = "0600";
      };
    };
  }
