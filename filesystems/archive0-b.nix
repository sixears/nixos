{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive0" = { label = "b-archive0"; fsType = "xfs"; };
  };
}
