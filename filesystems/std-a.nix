{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/"      = { label = "a-root";  fsType = "ext2"; };
    "/nix"   = { label = "a-nix";   fsType = "xfs";  };
    "/var"   = { label = "a-var";   fsType = "xfs";  };
    "/home"  = { label = "a-home";  fsType = "xfs";  };
    "/tmp"   = { label = "a-tmp";   fsType = "xfs";  };
  };

  swapDevices = [ { label = "a-swap"; } ];
}
