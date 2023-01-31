{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/local" = { label = "local"; fsType = "xfs";  };
  };
}
