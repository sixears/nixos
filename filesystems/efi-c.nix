{ config, lib, pkgs, ... }:

{
  fileSystems = {
#    "/backup2/boot"     = { label = "c-boot";   fsType = "vfat"; };
    "/backup2/boot/efi" = { label = "c-EFI"; fsType = "vfat"; };
  };
}
