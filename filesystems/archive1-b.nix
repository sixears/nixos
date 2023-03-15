{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive1" = { label = "b-archive1"; fsType = "xfs"; };
  };
}
