{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/"      = { label = "root";  fsType = "ext2"; };
    "/nix"   = { label = "nix";   fsType = "xfs";  };
    "/var"   = { label = "var";   fsType = "xfs";  };
    "/home"  = { label = "home";  fsType = "xfs";  };
    "/tmp"   = { label = "tmp";   fsType = "xfs";  };
  };

  swapDevices = [ { label = "swap"; } ];
}
