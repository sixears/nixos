{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "modesetting" ];
  # from xorg/overrides.nix:
  # error: xf86videointel has been removed as the package is unmaintained and
  # the driver is no longer functional.Please remove "intel" from
  # `services.xserver.videoDrivers` and switch to the "modesetting" driver.
  ## services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "TripleBuffer"    "true"
    Option "TearFree"    "true"
    # NOTE: Set DRI to false to prevent screen-tearing
    # on Abi's Dell 7306 2in1 Inspiron
    Option "DRI" "false"
#    Option "AccelMethod" "sna"
  '';
}
