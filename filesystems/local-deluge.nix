{ ... }:

{
  fileSystems = {
    "/Deluge" = { device  = "/local/deluge"; options = [ "bind" ]; };
  };
}
