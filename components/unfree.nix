{ pkgs, ... }:

with pkgs.lib;
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (getName pkg)
      [ "hplip" "nvidia-x11" "nvidia-settings" "plexmediaserver" "zoom" ];
}
