{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "TripleBuffer"    "true"
    Option "TearFree"    "true"
    # NOTE: Set DRI to false to prevent screen-tearing
    # on Abi's Dell 7306 2in1 Inspiron
    Option "DRI" "false"
#    Option "AccelMethod" "sna"
  '';
}
