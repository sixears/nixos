{ pkgs, bash-header, ... }:

#-#{ config, lib, pkgs, ... }:
#-#
{
  environment.systemPackages = with pkgs; [
    # !!! Do we really need these everywhere?
    (import ./pkgs/acme-cert.nix   { inherit pkgs; })
    (import ./pkgs/cert-expiry.nix { inherit pkgs; })

    (import ./pkgs/ip-public.nix { inherit pkgs; })

    (import ./pkgs/lumix-copy.nix  { inherit pkgs bash-header; })
    (import ./pkgs/pic-reduce.nix  { inherit pkgs bash-header; })

    alsaUtils
    coreutils
    dmidecode
    emacs
    fatrace
    file
    flameshot
    (import ./pkgs/fstab-check.nix { inherit pkgs; })


#-#      [
#-#        fstab-check
#-#        gptfdisk
#-#        # emacsWithPackages
#-#        haskellPackages.xmobar
#-#        # xmonad needs ghc in its path to compile
#-#        ghc
#-##        haskellPackages.xmonad
#-##        haskellPackages.xmonad-contrib
#-##        haskellPackages.xmonad-extras
#-#        hddtemp
#-#        hdparm
#-#        inetutils
#-#        git
#-#        gnumake
#-#        less
#-#        lm_sensors
#-#        lshw
#-#        lsof
#-#        man
#-#        man-pages
#-#        networkmanager
#-#        parted
#-#        pciutils
#-#        psmisc
#-#        smartmontools
#-#        sox
#-#        sudo
#-#        sysstat
#-#        thttpd
#-#        xkeyboard_config
#-#        vim
#-#        unzip
#-#
#-#        atop
#-#        htop
#-#    # doesn't build with 19.03.f29d398
#-#    #    ntopng
#-#        s-tui
#-#
#-#        # user assistance
#-#        xsession
#-#
#-#        sysdig
#-#        cryptsetup
  ];
}
