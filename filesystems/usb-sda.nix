{ config, lib, pkgs, ... }:

{
  fileSystems =
    {
      "/mnt/usb" =
        {
          device = "/dev/sda1";
          options = [ "user" "utf8" "umask=000" "noauto" "exec" "sync" ];
        };
    };
}
