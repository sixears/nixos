{ pkgs, bash-header, ... }:

let
 touchpad = import ./pkgs/touchpad.nix { inherit pkgs bash-header; };
in
  {
    environment.systemPackages = with pkgs; [
     rxvt_unicode-with-plugins i3status touchpad
      (xmonad-with-packages.override
        { packages = hPkgs: with hPkgs; [ xmonad-contrib ]; })
    ];

  services.xserver = {
    enable = true;

    # at the time of writing, this was literally the only thing that
    # worked :-(
    # see also displayManager.session
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
