{ ... }:

{
  # https://nixos.wiki/wiki/Stream_Deck
  # to ensure that udev rules are correctly enabled
  programs.streamdeck-ui =
    {
      enable = true;
      autoStart = false; # optional
    };
}
