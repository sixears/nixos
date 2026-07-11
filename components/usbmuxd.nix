{ pkgs, ... }: { # services.usbmuxd.enable = true;

services.usbmuxd = {
  enable = true;
  package = pkgs.usbmuxd2;
};         }
