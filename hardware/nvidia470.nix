{ config, ... }:

{
  # support GeForce GT 710
  hardware.nvidia.package =
    config.boot.kernelPackages.nvidiaPackages.legacy_470;
}
