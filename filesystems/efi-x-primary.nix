{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/boot/efi" = { label = "x-EFI"; fsType = "vfat"; };
  };
}
