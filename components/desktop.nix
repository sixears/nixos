# a set of standard packages to be available on all desktops
{ pkgs, my-pkgs, ... }:

{
  imports = [ ./unfree.nix ]; # for zoom

  environment.systemPackages = with pkgs; [
    audacious
    brave
    chromium
    claws-mail
    evince
    firefox
    # As of 24.11, 'gqview' has been removed due to lack of maintenance
    # upstream and depending on gtk2. Consider using 'gthumb' instead
    ## gqview
    gthumb
    imagemagick
    libheif
    libreoffice
    pcmanfm
    # shotwell depends on dconf for all its settings; but it's not a dependency
    # in the nix build
    shotwell dconf
    thunderbird

    my-pkgs.vlcp
    vlc

    zoom-us
  ];
}
