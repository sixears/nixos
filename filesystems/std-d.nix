{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup3/root"  = { label = "d-root";  fsType = "ext2"; };
    "/backup3/nix"   = { label = "d-nix";   fsType = "xfs";  };
    "/backup3/var"   = { label = "d-var";   fsType = "xfs";  };
    "/backup3/home"  = { label = "d-home";  fsType = "xfs";  };
    "/backup3/tmp"   = { label = "d-tmp";   fsType = "xfs";  };
  };

#  swapDevices = [ { label = "d-swap"; } ];
}
