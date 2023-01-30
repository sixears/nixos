{ config, lib, pkgs, ... }:

{
  # enable sar collection
  services.sysstat = {
    enable            = true;
    collect-frequency = "*:*:0/10";
    collect-args      = "-C XALL 1 1";
  };
}
