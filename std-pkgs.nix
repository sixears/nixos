{}:

#-#{ config, lib, pkgs, ... }:
#-#
#-#let
#-#  header          = import ../../nixpkgs/configs/scripts/src/header.nix { inherit pkgs; };
#-#  hello-world-src = import ./scripts/hello-world { inherit pkgs; };
#-#  hello-world     = pkgs.writers.writeBashBin "hello-world" hello-world-src;
#-#  lumix-copy      = import ./scripts/lumix-copy { inherit header pkgs; };
#-#  pic-reduce      = let
#-#                      src = import ./scripts/pic-reduce.nix { inherit pkgs; };
#-#                    in
#-#                      pkgs.writers.writeBashBin "pic-reduce" src;
#-# in
  {
    environment.systemPackages = with pkgs; [
#-#      [
#-#        acme-cert cert-expiry
#-#        hello-world
#-#        lumix-copy
#-#        pic-reduce
#-#
#-#        nixos-cfg
#-#
#-#        alsaUtils
#-#        coreutils
#-#        dkill-scripts
#-#        dmidecode
#-#        emacs
#-#        # shouldn't be necessary with kernel >= 5.18; indeed, won't build
#-#        # (pkgs/os-specific/linux/exfat/default.nix)
#-#        # exfat
#-#        fatrace
#-#        file
#-#        flameshot
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
