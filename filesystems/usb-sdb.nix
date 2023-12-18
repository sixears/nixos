{ ... }:

{
  fileSystems =
    {
      "/mnt/usb" =
        {
          device = "/dev/sdb1";
          options = [ "user" "utf8" "umask=000" "noauto" "exec" "sync" ];
        };
    };
}
