{ ... }:

{
  # The option definition `programs.adb' in
  # `/nix/store/bsrlg2wk6p2zm85n8d5q42rygm0qm7i6-source/components/adb.nix' no
  # longer has any effect; please remove it.This option is no longer needed as
  # systemd 258 handles uaccess rules automatically. Please add
  # `pkgs.android-tools` to your system packages to get the adb command
  programs.adb.enable = true;
}
