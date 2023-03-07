{ ... }:

{
  # 60C info, 70C warning on nvme.  These are still probably very conservative,
  # and anyway it will throttle (probably at a higher temp than this) rather
  # than suffering damage.
  # https://forums.guru3d.com/threads/what-should-normal-safe-operating-temperature-be-for-a-m-2-nvme-drive.418369/
  services.smartd.devices =
    [ { device="/dev/nvme0"; options = "-d nvme -W 0,70,75"; } ];

  boot.initrd.availableKernelModules = [ "nvme" ];
}
