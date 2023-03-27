{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive6"    = { label = "b-archive6"; fsType = "xfs"; };

    "/backup2/Deluge"          = { device = "/backup/archive6/Deluge"          ; options = [ "bind" ]; };
    "/backup/Cam-Archive"         = { device = "/backup/archive6/Cam-Archive"         ; options = [ "bind" ]; };
  };
}
