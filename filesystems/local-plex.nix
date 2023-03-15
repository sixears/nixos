{ ... }:

{
  fileSystems = {
    "/var/lib/plex" = { device = "/local/plex"; options = [ "bind" ]; };
  };
}
