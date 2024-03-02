{ pkgs, ... }:

{
  services.keyd = {
    enable = true;
    keyboards.default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";

            leftalt = "leftalt";
            # leave rightalt as rightalt (as a one-hit), so that the compose (in
            # xkb) does its thing; messing with that is a fools game
            # but we can overload its held-down behaviour; the first argument to
            # overload is a layer name (see layer definition below); thus this
            # means "use rightalt layer when held; use rightalt key (mapped by
            # xkb to "compose" when tapped"
            rightalt = "overload(rightalt,rightalt)";

            # on Dell XPS, this is the backslash/pipe key at the bottom left
            # between the Shift and the Z
            "102nd" = "f13";
          };

          rightalt = {
            h = "left";
            j = "down";
            k = "up";
            l = "right";
            # note that we have mapped rightalt to compose in xkb
            g = "macro(rightalt 3)";
            # really, 3-l; but keyd is the lowest level, the 'p' will
            # get translated to an 'l'
            "3" = "macro(rightalt 3 p)";
            # really, 4-e; but keyd is the lowest level, the 'd' will
            # get translated to an 'e'
            "4" = "macro(rightalt 4 d)";
            "#" = "macro(rightalt 0 4)";
            f = "¢";
            d = "ç";
          };

          # can't get rightalt + alt to work together
          "rightalt+shift" = {
            h = "macro(rightalt 0 4)";
          };
          "rightalt+control" = {
            h = "macro(rightalt 0 0 5)";
          };
          "rightalt+meta" = {
            h = "macro(rightalt 3)";
          };
        };
        extraConfig = ''
          [global]
          layer_indicator = 1;
        '';
    };
  };
}
