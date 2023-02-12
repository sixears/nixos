{ ... }:

{
  services.smartd.devices =
    [ { device="/dev/nvme0"; options = "-d nvme -W 0,70,75"; } ];

  boot.initrd.availableKernelModules = [ "nvme" ];
}
