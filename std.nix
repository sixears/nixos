{ hostname, domainname, etherMac, stateVersion, systemPackages, logicalCores
, boot      ? ./boot/efi.nix
, sshPubKey ? ./sshkeys + "/${hostname}.pub"
}:

{ lib, pkgs, ... }:

let
  filesystems = [ ./filesystems/std.nix ];
in
  {
    # Every once in a while, a new NixOS release may change configuration
    # defaults in a way incompatible with stateful data. For instance, if the
    # default version of PostgreSQL changes, the new version will probably be
    # unable to read your existing databases. To prevent such breakage, you
    # should set the value of this option to the NixOS release with which you
    # want to be compatible. The effect is that NixOS will use defaults
    # corresponding to the specified release (such as using an older version of
    # PostgreSQL). It‘s perfectly fine and recommended to leave this value at
    # the release version of the first install of this system. Changing this
    # option will not upgrade your system. In fact it is meant to stay constant
    # exactly when you upgrade your system. You should only bump this option, if
    # you are sure that you can or have migrated all state on your system which
    # is affected by this option.
    system.stateVersion = stateVersion;

    # This option defines the maximum number of jobs that Nix will try to build
    # in parallel. The default is auto, which means it will use all available
    # logical cores. It is recommend to set it to the total number of logical
    # cores in your system (e.g., 16 for two CPUs with 4 cores each and
    # hyper-threading).
    nix.settings.max-jobs = lib.mkDefault logicalCores;

    # from nixpkgs/nixos/modules/installer/scan/not-detected.nix
    # Enables non-free firmware on devices not recognized by
    # `nixos-generate-config`.
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" "sd_mod" ];

    environment.systemPackages = systemPackages pkgs;

    nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (pkgs.lib.getName pkg)
          [ "hplip" "nvidia-x11" "nvidia-settings" "plexmediaserver" ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # -- ssh -----------------------------------------------

    programs.ssh.knownHosts =
      { "localhost" = { publicKeyFile = sshPubKey; }; };

    # -- networking ----------------------------------------

    networking = {
      hostName = hostname;
      extraHosts =
        "127.0.0.1 " + hostname + "." + domainname + " " + hostname;

      networkmanager = { enable = true;
                         # note that this won't effect until ethernet is
                         # actually connected
                         ethernet.macAddress = etherMac; };

      enableIPv6 = false;
      nameservers = [
        "103.247.36.36" # dns1.dnsfilter.com
        "103.247.37.37" # dns2.dnsfilter.com
      ];
      search = [ "sixears.co.uk" ];
      domain = "sixears.co.uk";
    };

    # -- display -----------------------------------------

    # Enable acpilight.  This will allow brightness control via xbacklight
    # from users in the video group.
    hardware.acpilight.enable = true; programs.light.enable = true;

    # create a symlink to /etc/X11/xorg.conf for visibility
    services.xserver.exportConfiguration = true;

    # -- nixos caches ------------------------------------

    nix.settings = {
      substituters = [
        "http://nixos-bincache.sixears.co.uk:5000/"
        "http://night.sixears.co.uk:5000/"
        "https://cache.iog.io" # See ref (01)

      ];

      #

      trusted-public-keys = lib.mapAttrsToList (x: y: x + ":" + y) ({
        # See ref (01)
        "hydra.iohk.io" = "f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=";
     } // (with lib.attrsets;
           mapAttrs' (k: v: nameValuePair (k + ".sixears.co.uk") v) {
        "nixos-bincache" = "qdbId5CKN01tH6SWL0YUsIG5fUmdZKRgYQ8Hh2C3STg=";
        "trance"         = "M2ebZ15Yk6V9Pi81MldTgNY7KdLukDj2rhzLibwq0t0=";
        "night"          = "uPZcQccenrbEivJ3vEHZtoybCQYxOQOJqQg4H6aQJm8=";
      }));
    };

    # ----------------------------------------------------

    imports = [ boot ] ++ filesystems;
  }

# ==============================================================================

# References
# (01) https://input-output-hk.github.io/haskell.nix/tutorials/getting-started-flakes.html

# -- that's all, folks! --------------------------------------------------------

  #-#  systemd.services.nix-daemon.environment.TMPDIR = "/local/tmp/nix-daemon";
  #-#
  #-#  security.pki.certificateFiles = [ ./cert.pem ];
  #-#
  #-#  services.emacs = {
  #-#    defaultEditor = true;
  #-##    no good - doesn't have (e.g.,) ssh keys, or the right tmpdir
  #-##    enable = true;
  #-#  };
  #-#
  #-#  services.locate.enable = true;
  #-#
  #-## 22.05
  #-#  security.acme.defaults.email = "root@sixears.co.uk";
  #-##  security.acme.email = "root@sixears.co.uk";
  #-#  security.acme.acceptTerms    = true;
  #-#
  #-#  # Select internationalisation properties.
  #-#  console.keyMap     = ./keys.map; # "dvorak";
  #-#  i18n.defaultLocale = "en_GB.UTF-8";
  #-#
  #-#  # Set your time zone.
  #-#  time.timeZone = "Etc/GMT";
  #-#
  #-#  imports = [
  #-#              ./overlays.nix
  #-##              ./overlays2.nix
  #-#              ./packages.nix
  #-#
  #-#              ./sixears-hosts.nix
  #-#
  #-#              ./fcron.nix
  #-#              ./msmtp.nix
  #-#
  #-#              ./prometheus.nix
  #-#              ./openssh.nix
  #-#              ./sshkeys.nix
  #-#
  #-#              ./smartd.nix
  #-#              ./sysstat.nix
  #-#
  #-#              ./disthttpd.nix
  #-#
  #-##             this doesn't easily co-exist with home-backup.nix
  #-##              ./local-home-backup.nix
  #-#
  #-#              ./xresources.nix
  #-#
  #-##             removed from nix :-(
  #-##              ./osquery.nix
  #-#            ];
  #-##  nixpkgs.config.firefox.enableAdobeFlash = true;
  #-##  nixpkgs.config.chromium.enableAdobeFlash = true;
  #-##  nixpkgs.config.chromium.enablePepperFlash = true;
  #-#
  #-#  sound.enable = true;
  #-#
  #-#  security.sudo.extraRules =
  #-#    [
  #-#      { commands = [ { command  = "/run/current-system/sw/bin/cupsenable";
  #-#                       options  = [ "NOPASSWD" ]; }
  #-#                   ];
  #-#        users    = [ "martyn" "abigail" "heather" "xander" "jj" ];
  #-#      }
  #-#    ];
  #-#
  #-#  # regrettably, this seems to be destined never to be supported in nixos
  #-#  # https://github.com/NixOS/nixpkgs/issues/9848
  #-#  security.wrappers.mount = {
  #-#    source = "${pkgs.utillinux}/bin/mount";
  #-#    owner = "root";
  #-#    group = "root";
  #-##    setgid = true;
  #-#    setuid = true;
  #-#  };
  #-#  security.wrappers.umount = {
  #-#    source = "${pkgs.utillinux}/bin/umount";
  #-#    owner = "root";
  #-#    group = "root";
  #-##    setgid = true;
  #-#    setuid = true;
  #-#  };
  #-#
  #-#  environment.etc.nixos-cfg.source = "${pkgs.nixos-cfg}";
  #-#
  #-#  programs.sysdig.enable = true;
