# 2025-11-22 - we don't need this, we use sudo systemctl start openvpn-*
{ pkgs, bash-header, ... }:

let
  vpn = import ../pkgs/vpn.nix { inherit pkgs bash-header; };
in
  {
    security.wrappers.vpn = {
      source = vpn;
      owner = "root";
      group = "root";
      setgid = true;
      setuid = true;
    };
  }
