{ config, lib, pkgs, ... }:

{
  fileSystems = {
#    "/boot"     = { label = "boot";   fsType = "vfat"; };
    "/boot/efi" = { label = "EFI"; fsType = "vfat"; };
  };
}
