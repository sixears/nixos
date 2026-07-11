{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive2" = { label = "a-archive2"; fsType = "xfs"; };

    "/Music"         = { device = "/archive2/Music"  ;
                         options = [ "bind" ]; fsType = "none"; };
    "/Deluge"        = { device = "/archive2/Deluge" ;
                         options = [ "bind" ]; fsType = "none"; };
    "/nsa3"          = { device = "/archive2/nsa3"   ;
                         options = [ "bind" ]; fsType = "none"; };

    "/backup2/local" = { device = "/archive2/local"  ;
                         options = [ "bind" ]; fsType = "none"; };
  };

  imports = [
    ../components/nfs-server.nix
  ];

  services.nfs.server.exports = ''
    /Music   192.168.0.0/24
  '';
}
