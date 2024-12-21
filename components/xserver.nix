{ pkgs, bash-header, my-pkgs, dvorak ? false, ... }:

let
#  touchpad = import ../pkgs/touchpad.nix { inherit pkgs bash-header; };
  xkb      = import ../pkgs/xkb.nix      { inherit pkgs; };
  xmonad-with-pkgs =
    pkgs.xmonad-with-packages.override
      { packages = hPkgs: with hPkgs; [ base-unicode-symbols data-default
                                        xmonad-contrib ]; };
in
  {
    environment.systemPackages = with pkgs; [
      # xmonad needs ghc in its path to compile
      # ghc
      i3status
      # Pre-24.11
      # rxvt_unicode-with-plugins
      rxvt-unicode
      my-pkgs.touchpad
      xkb
      xkeyboard_config
      xmonad-with-pkgs
      (import ../pkgs/xsession.nix { inherit pkgs xkb xmonad-with-pkgs; })
    ];

    services.libinput.enable = true;
    # at the time of writing (2023-01-27, creating first full nixos flake),
    # this was literally the only thing that built :-( but maybe
    # displayManager.session can help?
    services.displayManager.defaultSession = "none+xmonad";

    services.xserver = {
      enable = true;

      windowManager = {
        xmonad.enable = true;
        xmonad.enableContribAndExtras = true;
      };

      # I did try a big ole // if dvorak then { ... } else { ... } after the
      # main { ... }, but that caused the display-manager service to stop on
      # build; I'm pretty sure that the two sets of services.xserver don't merge
      # nicely in that way
      xkb = {
        layout  = if dvorak then "dvorak" else "gb";
        options =
          if dvorak
          then "caps:ctrl_modifier compose:prsc altwin:menu eurosign:4"
          else "eurosign:4";
      };
    };

    environment.etc = {
      xmonad-hs =
        {
          source = import ../pkgs/xmonad-hs.nix { inherit pkgs;
                                                  inherit (my-pkgs) touchpad; };
          target = "xmonad.hs";
        };

      xmobarrc = { source = ../pkgs/xmobarrc; };
      i3status = { source = ../pkgs/i3status; };

      xresources-urxvt =
        {
          source = import ../pkgs/xresources/urxvt.nix { inherit pkgs; };
          target = "Xresources/urxvt";
        };
    };
  }
