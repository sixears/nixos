{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive5"   = { label = "b-archive5"; fsType = "xfs"; };

    "/backup/nsa"        = { device  = "/backup/archive5/nsa";
                             options = [ "bind" ]; };
  };
}
