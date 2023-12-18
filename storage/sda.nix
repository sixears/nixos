{ ... }:

{
  services.smartd.devices =
    [ { device="/dev/sda"; options = "-d nvme -W 0,70,75"; } ];
}
