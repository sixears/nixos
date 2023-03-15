{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/local" = { label = "b-local"; fsType = "xfs";  };
  };
}
