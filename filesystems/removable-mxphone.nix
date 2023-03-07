{ ... }:

{
  fileSystems = {
    "/mnt/mxphone" = { device = "/dev/disk/by-uuid/3EC7-1AE4";
                       options = [ "user" "noauto" "sync" ]; };
  };
}
