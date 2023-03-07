{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive2" = { label = "a-archive2"; fsType = "xfs"; };

    "/Music"         = { device = "/archive2/Music"  ; options = [ "bind" ]; };
    "/Deluge"        = { device = "/archive2/Deluge" ; options = [ "bind" ]; };
    "/backup2/local" = { device = "/archive2/local"  ; options = [ "bind" ]; };
  };

  imports = [
    ../components/nfs-server.nix
  ];

  services.nfs.server.exports = ''
    /Music   192.168.0.0/24
  '';
}
