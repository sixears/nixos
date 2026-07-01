{ config, ... }:

{
  # boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtw89 ];
}
