{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/"      = { label = "x-root";  fsType = "ext2"; };
    "/nix"   = { label = "x-nix";   fsType = "xfs";  };
    "/var"   = { label = "x-var";   fsType = "xfs";  };
    "/home"  = { label = "x-home";  fsType = "xfs";  };
    "/tmp"   = { label = "x-tmp";   fsType = "xfs";  };
  };

  swapDevices = [ { label = "x-swap"; } ];
}
