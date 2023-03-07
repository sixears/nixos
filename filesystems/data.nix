{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/data" = { label = "data"; fsType = "xfs";  };
  };
}
