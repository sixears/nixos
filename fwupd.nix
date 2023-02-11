{ pkgs, ... }:

# https://nixos.wiki/wiki/Fwupd
# https://github.com/fwupd/fwupd
# Dell XPS13 9315 (red) : https://fwupd.org/lvfs/devices/com.dell.uefi53f6a2fd.firmware
{
#  environment.systemPackages =
#    with pkgs; [ fwupd ];
  services.fwupd.enable = true;
}
