{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive2" = { label = "b-archive2"; fsType = "xfs"; };

    "/backup/Music"    = { device = "/backup/archive2/Music"  ; options = [ "bind" ]; };
    "/backup/Deluge"   = { device = "/backup/archive2/Deluge" ; options = [ "bind" ]; };
    "/backup/local"    = { device = "/backup/archive2/local"  ; options = [ "bind" ]; };
  };
}
