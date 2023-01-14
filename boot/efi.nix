{ config, lib, pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      efiSysMountPoint     = "/boot/efi";
      canTouchEfiVariables = true;
    };

    # Whether to invoke grub-install with --removable

    # Unless you turn this on, GRUB will install itself somewhere in
    # boot.loader.efi.efiSysMountPoint (exactly where depends on other config
    # variables). If you've set boot.loader.efi.canTouchEfiVariables *AND* you
    # are currently booted in UEFI mode, then GRUB will use efibootmgr to modify
    # the boot order in the EFI variables of your firmware to include this
    # location. If you are *not* booted in UEFI mode at the time GRUB is being
    # installed, the NVRAM will not be modified, and your system will not find
    # GRUB at boot time. However, GRUB will still return success so you may miss
    # the warning that gets printed ("efibootmgr: EFI variables are not
    # supported on this system.").

    # If you turn this feature on, GRUB will install itself in a special
    # location within efiSysMountPoint (namely EFI/boot/boot$arch.efi) which the
    # firmwares are hardcoded to try first, regardless of NVRAM EFI variables.

    # To summarize, turn this on if:
    # - You are installing NixOS and want it to boot in UEFI mode, but you are
    #   currently booted in legacy mode
    # - You want to make a drive that will boot regardless of the NVRAM state of
    #   the computer (like a USB "removable" drive)
    # - You simply dislike the idea of depending on NVRAM state to make your
    #   drive bootable
    
    # grub.efiInstallAsRemovable = true;
    # grub.efiSupport            = true;
  };
}
