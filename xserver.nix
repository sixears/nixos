{ pkgs, bash-header, ... }:

let
  touchpad = import ./pkgs/touchpad.nix { inherit pkgs bash-header; };
  xkb      = import ./pkgs/xkb.nix      { inherit pkgs; };
  xmonad-with-pkgs =
    pkgs.xmonad-with-packages.override
      { packages = hPkgs: with hPkgs; [ xmonad-contrib ]; };
in
  {
    environment.systemPackages = with pkgs; [
      # xmonad needs ghc in its path to compile
      # ghc
      i3status
      rxvt_unicode-with-plugins
      touchpad
      xkb
      xkeyboard_config
      xmonad-with-pkgs
      (import ./pkgs/xsession.nix { inherit pkgs xkb xmonad-with-pkgs; })
    ];

  services.xserver = {
    enable = true;

    # at the time of writing (2023-01-27, creating first full nixos flake), this
    # was literally the only thing that built :-(
    # but maybe displayManager.session can help?
    displayManager.defaultSession = "none+xmonad";

    windowManager = {
      xmonad.enable = true;
      xmonad.enableContribAndExtras = true;
    };
  };

    environment.etc =
      {
        xmonad-hs =
          {
            source = import ./pkgs/xmonad-hs.nix { inherit pkgs touchpad; };
            target = "xmonad.hs";
          };

        xmobarrc = { source = ./pkgs/xmobarrc; };
        i3status = { source = ./pkgs/i3status; };
      };
  }
