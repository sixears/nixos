{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive2" = { label = "b-archive2"; fsType = "xfs"; };

    "/backup/Music"    = { device = "/backup/archive2/Music"  ;
                           options = [ "bind" ]; fsType = "none"; };
    "/backup/Deluge"   = { device = "/backup/archive2/Deluge" ;
                           options = [ "bind" ]; fsType = "none"; };
    "/backup/nsa3"     = { device  = "/backup/archive2/nsa3"  ;
                           options = [ "bind" ]; fsType = "none"; };
    "/backup/local"    = { device = "/backup/archive2/local"  ;
                           options = [ "bind" ]; fsType = "none"; };
  };
}
