{ pkgs, bash-header, ... }:

{
  security.wrappers.vpn = {
    source = ./import ../pkgs/vpn.nix { pkgs, bash-header };
    owner = "root";
    group = "root";
    setgid = true;
    setuid = true;
  };
}
