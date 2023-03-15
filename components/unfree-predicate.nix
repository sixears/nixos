{ pkgs }: p:
  builtins.elem (pkgs.lib.getName p)
                [ "hplip" "nvidia-x11" "nvidia-settings" "plexmediaserver" ]
