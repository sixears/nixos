{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive5" = { label = "a-archive5"; fsType = "xfs"; };

    "/nsa"      = { device = "/archive5/nsa"; options = [ "bind" ]; };
  };
}
