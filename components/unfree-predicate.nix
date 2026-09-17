{ pkgs }: p:
  builtins.elem (pkgs.lib.getName p) [
    "broadcom-sta" "hplip" "mongodb" "nvidia-kernel-modules" "nvidia-settings"
    "nvidia-x11" "plexmediaserver" "steam" "steam-original" "unifi-controller"
    "unrar" "zoom"
  ]
