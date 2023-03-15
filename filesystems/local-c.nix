{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup2/local" = { label = "c-local"; fsType = "xfs";  };
  };
}
