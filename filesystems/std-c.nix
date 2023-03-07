{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup2/root"  = { label = "c-root";  fsType = "ext2"; };
    "/backup2/nix"   = { label = "c-nix";   fsType = "xfs";  };
    "/backup2/var"   = { label = "c-var";   fsType = "xfs";  };
    "/backup2/home"  = { label = "c-home";  fsType = "xfs";  };
    "/backup2/tmp"   = { label = "c-tmp";   fsType = "xfs";  };
  };

#  swapDevices = [ { label = "c-swap"; } ];
}
