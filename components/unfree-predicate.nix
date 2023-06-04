{ pkgs }: p:
  builtins.elem (pkgs.lib.getName p) [
    "broadcom-sta" "hplip" "nvidia-x11" "nvidia-settings" "plexmediaserver"
    "steam" "steam-original" "zoom"
  ]
