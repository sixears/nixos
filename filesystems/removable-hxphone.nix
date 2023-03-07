{ ... }:

{
  fileSystems = {
    "/mnt/hxphone" = { device = "/dev/disk/by-uuid/0D32-51DB";
                       options = [ "user" "noauto" "sync" ]; };
  };
}
