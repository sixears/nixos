{ config, lib, pkgs, ... }:

# A 'b' system with no nix because dog's second SSD doesn't have
# enough space
{
  fileSystems = {
    "/backup/root"  = { label = "b-root";  fsType = "ext2"; };
##  "/backup/nix"   = { label = "b-nix";   fsType = "xfs";  };
    "/backup/var"   = { label = "b-var";   fsType = "xfs";  };
    "/backup/home"  = { label = "b-home";  fsType = "xfs";  };
    "/backup/tmp"   = { label = "b-tmp";   fsType = "xfs";  };
  };

#  swapDevices = [ { label = "b-swap"; } ];
}
