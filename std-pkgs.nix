{ pkgs, bash-header, hlib, ... }:

let
  touchpad = import ./pkgs/touchpad.nix { inherit pkgs bash-header; };
  tablify  = import ./pkgs/tablify.nix { inherit pkgs hlib; };
in
  {
    environment.systemPackages = with pkgs; [
      tablify

      (import ./pkgs/nix-install.nix   { inherit pkgs; })
      (import ./pkgs/nix-search.nix    { inherit pkgs tablify; })
      (import ./pkgs/rtunnel.nix       { inherit pkgs; })
      (import ./pkgs/wifi-pw-write.nix { inherit pkgs; })

      # !!! Do we really need these everywhere?
      (import ./pkgs/acme-cert.nix   { inherit pkgs; })
      (import ./pkgs/cert-expiry.nix { inherit pkgs; })

      (import ./pkgs/ip-public.nix { inherit pkgs; })

      # 2025-11-22 - we don't need this, we use sudo systemctl start openvpn-*
      # (import ./pkgs/openvpn-import.nix  { inherit pkgs bash-header; })
      (import ./pkgs/pic-reduce.nix  { inherit pkgs bash-header; })
      (import ./pkgs/stc.nix  { inherit pkgs bash-header; })

      (import ./pkgs/email.nix  { inherit pkgs bash-header; })

      # Pre-24.11
      # alsaUtils
      alsa-utils
      bat
      coreutils
      dmidecode
      (import ./pkgs/dfhl.nix { inherit pkgs; })
      emacs
      ethtool
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
      inotify-tools
      less
      lm_sensors
      lshw
      lsof
      man
      man-pages
      ncdu dust gdu dua
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
      tree
      vim
      unzip
      usbutils

      atop
      htop
      ntopng
      s-tui
      sysdig
      cryptsetup
      pavucontrol

      hwloc

      nix-du
      nix-tree
      nix-output-monitor

      # iphone mount
      libimobiledevice
      ifuse

      keepassxc
      # generate passwords with xkcdpass --min 4 --max 8 -n 4 -d -
      xkcdpass

      librewolf
    ];
  }
