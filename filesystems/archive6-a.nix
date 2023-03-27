{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive6"    = { label = "a-archive6"; fsType = "xfs"; };

    "/backup/Deluge"          = { device = "/archive6/Deluge"          ; options = [ "bind" ]; };
    "/Cam-Archive"         = { device = "/archive6/Cam-Archive"         ; options = [ "bind" ]; };
  };
}
