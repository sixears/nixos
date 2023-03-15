{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/local" = { label = "x-local"; fsType = "xfs";  };
  };
}
