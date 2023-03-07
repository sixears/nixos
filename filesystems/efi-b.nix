{ config, lib, pkgs, ... }:

{
  fileSystems = {
#    "/backup/boot"     = { label = "b-boot";   fsType = "vfat"; };
    "/backup/boot/efi" = { label = "b-EFI"; fsType = "vfat"; };
  };
}
