{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive3" = { label  = "a-archive3"    ; fsType = "xfs";       };

    "/TV"       = { device = "/archive3/TV"  ; options = [ "bind" ]; };
  };
}
