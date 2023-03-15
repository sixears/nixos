{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/root"  = { label = "b-root";  fsType = "ext2"; };
    "/backup/nix"   = { label = "b-nix";   fsType = "xfs";  };
    "/backup/var"   = { label = "b-var";   fsType = "xfs";  };
    "/backup/home"  = { label = "b-home";  fsType = "xfs";  };
    "/backup/tmp"   = { label = "b-tmp";   fsType = "xfs";  };
  };

#  swapDevices = [ { label = "b-swap"; } ];
}
