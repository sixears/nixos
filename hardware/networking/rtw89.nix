{ config, ... }:

{
  boot.kernelModules = [ "rtw89" ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.rtw89 ];
}
