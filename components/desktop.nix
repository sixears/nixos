# a set of standard packages to be available on all desktops
{ pkgs, ... }:

{
  imports = [ ./unfree.nix ]; # for zoom

  environment.systemPackages = with pkgs; [
    audacious
    brave
    chromium
    claws-mail
    evince
    firefox
    gqview
    imagemagick
    libheif
    libreoffice
    pcmanfm
    # shotwell depends on dconf for all its settings; but it's not a dependency
    # in the nix build
    shotwell dconf
    thunderbird

    (import ../pkgs/vlcp.nix { inherit pkgs; })
    vlc

    zoom-us
  ];
}
