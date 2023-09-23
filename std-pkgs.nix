{ pkgs, bash-header, ... }:

let
 touchpad = import ./pkgs/touchpad.nix { inherit pkgs bash-header; };
in
  {
    environment.systemPackages = with pkgs; [
      (import ./pkgs/nix-install.nix { inherit pkgs; })
      (import ./pkgs/nix-search.nix  { inherit pkgs; })

      # !!! Do we really need these everywhere?
      (import ./pkgs/acme-cert.nix   { inherit pkgs; })
      (import ./pkgs/cert-expiry.nix { inherit pkgs; })

      (import ./pkgs/ip-public.nix { inherit pkgs; })

      (import ./pkgs/pic-reduce.nix  { inherit pkgs bash-header; })

      alsaUtils
      bat
      coreutils
      dmidecode
      emacs
      fatrace
      fd
      file
      flameshot
      (import ./pkgs/fstab-check.nix { inherit pkgs; })

      hddtemp
      hdparm
      inetutils
      inxi
      git
      gnumake
      less
      lm_sensors
      lshw
      lsof
      man
      man-pages
      networkmanager
      patdiff
      pciutils
      psmisc
      ripgrep
      silver-searcher
      smartmontools
      sox
      sudo
      sysstat
      vim
      unzip
      usbutils

      atop
      htop
      ntopng
      s-tui
      sysdig
      cryptsetup

      hwloc
    ];
  }
