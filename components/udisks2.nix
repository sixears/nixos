# https://wiki.nixos.org/wiki/USB_storage_devices
{ ... }: { services.udisks2.enable = true; }
