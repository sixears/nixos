{ pkgs }: p:
  builtins.elem (pkgs.lib.getName p) [
    "broadcom-sta" "hplip" "mongodb" "nvidia-x11" "nvidia-settings"
    "plexmediaserver" "steam" "steam-original" "unifi-controller" "unrar" "zoom"
  ]
