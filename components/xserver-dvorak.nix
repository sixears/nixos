{ config, lib, pkgs, ... }:

{
  services.xserver.layout     = "dvorak";
  # use left-alt+4 for euro
  services.xserver.xkbOptions = "caps:ctrl_modifier compose:prsc altwin:menu eurosign:4";
}
