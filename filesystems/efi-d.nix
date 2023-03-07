{ config, lib, pkgs, ... }:

{
  fileSystems = {
#    "/backup3/boot"     = { label = "d-boot";   fsType = "vfat"; };
    "/backup3/boot/efi" = { label = "d-EFI"; fsType = "vfat"; };
  };
}
