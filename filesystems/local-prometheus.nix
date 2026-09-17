{ ... }:

{
  fileSystems = {
    "/var/lib/prometheus" = { device  = "/local/prometheus";
                              options = [ "bind" ];
                              fsType = "none";
                            };
  };
}
