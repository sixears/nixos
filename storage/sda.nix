{ ... }:

{
  services.smartd.devices =
    [ { device="/dev/sda"; options = "-W 0,70,75"; } ];
}
