{ pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg)
      [ "hplip" "nvidia-x11" "nvidia-settings" "plexmediaserver" ];
}
