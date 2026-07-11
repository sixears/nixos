# https://wiki.nixos.org/wiki/USB_storage_devices
{ pkgs, ... }:

{
  services.udisks2.enable = true;
#  environment.systemPackages = with pkgs; [udiskie];
}
