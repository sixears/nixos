{ config, lib, pkgs, ... }:

{
  boot.loader.grub = {
    # Use the GRUB 2 boot loader.
    enable = true;
    version = 2;
    # boot.loader.grub.efiSupport = true;
    # boot.loader.grub.efiInstallAsRemovable = true;
    # boot.loader.efi.efiSysMountPoint = "/boot/efi";
    # Define on which hard drive you want to install Grub.
    device = "/dev/sda"; # or "nodev" for efi only
  };
}
