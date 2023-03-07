{ config, lib, pkgs, ... }:

{
  virtualisation.virtualbox.host.enable = true;
  users.users.martyn.extraGroups = [ "vboxusers" ];
}
  
