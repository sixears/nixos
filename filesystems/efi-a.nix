{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/boot/efi" = { label = "a-EFI"; fsType = "vfat"; };
  };
}
