{ pkgs, ... }:

{
  boot.kernelModules = [ "iwlwifi" ];
  hardware.firmware = {
    enable = true;
    packages = [ pkgs.iwlwifi-firmware ];
  };
}
