{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup3/local" = { label = "d-local"; fsType = "xfs";  };
  };
}
