{ config, lib, pkgs, ... }:

{
  virtualisation.docker = { enable = true; extraOptions = "-g /local/docker"; };
  users.users.martyn.extraGroups = [ "docker" ];

  # see https://gist.github.com/lanrat/458066dbdeb460b9cef40dc2af639a24
  networking.networkmanager.unmanaged = [ "interface-name:docker0" "interface-name:veth*" "interface-name:br*" ];
}
  
