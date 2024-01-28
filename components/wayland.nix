{ pkgs, bash-header, my-pkgs, dvorak ? false, ... }:

let
#  xkb      = import ../pkgs/xkb.nix      { inherit pkgs; };
in
  {
    # add the following line somewhere in `configuration.nix`
    # for example, in between locales and audio sections
    programs.sway.enable = true;
  }
