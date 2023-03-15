{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive3" = { label = "b-archive3"; fsType = "xfs"; };
  };
}
