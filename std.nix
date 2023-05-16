{ hostname, domainname, stateVersion, systemPackages, logicalCores, system
, filesystems, imports
, bash-header
, boot      ? ./boot/efi.nix
, sshPubKey ? ./sshkeys + "/${hostname}.pub"
, cpuFreqGovernor ? "ondemand"
}:

{ lib, pkgs, ... }:

let
  std-filesystems = [ ];
  nixos-cfg       = import ./nixos-cfg { inherit pkgs system; };
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

    # from nixpkgs/nixos/modules/installer/scan/not-detected.nix
    # Enables non-free firmware on devices not recognized by
    # `nixos-generate-config`.
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.initrd.availableKernelModules = [ "usb_storage" "sd_mod" ];

    environment.systemPackages = systemPackages pkgs;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # these users can, e.g., build & install from remote
    # see https://nixos.wiki/wiki/Nixos-rebuild
    nix.settings.trusted-users = [ "martyn" ];

    environment.etc.nixos-cfg.source = "${nixos-cfg}";

    programs.sysdig.enable = true;

    powerManagement.cpuFreqGovernor = cpuFreqGovernor;

    # -- ssh -----------------------------------------------

    programs.ssh.knownHosts =
      { "localhost" = { publicKeyFile = sshPubKey; }; };

    # -- sudo ----------------------------------------------

    # we allow nopasswd for wheel in part to allow remote rebuilding with --with-remote-sudo
    security.sudo = { execWheelOnly = true; wheelNeedsPassword = false; };

    # -- audio ---------------------------------------------

    sound.enable = true;

    # -- (u)mount ------------------------------------------

    # regrettably, this seems to be destined never to be supported in nixos
    # https://github.com/NixOS/nixpkgs/issues/9848
    security.wrappers.mount = {
      source = "${pkgs.utillinux}/bin/mount";
      owner = "root"; group = "root"; setuid = true;
    };
    security.wrappers.umount = {
      source = "${pkgs.utillinux}/bin/umount";
      owner = "root"; group = "root"; setuid = true;
    };

    # ------------------------------------------------------

    imports = (imports pkgs) ++ [
      (import ./std-pkgs.nix { inherit pkgs bash-header; })

      ./components/remote-nixos-caches.nix
      boot
      (import ./components/networking.nix { inherit hostname domainname; })
      ./components/tz-gmt.nix
      (import ./components/nix-daemon.nix { inherit logicalCores; })
      ./components/keyboard.nix
      ./components/display.nix
      ./components/locate.nix
      ./components/acme.nix
      ./components/unfree.nix
      ./components/sixears-hosts.nix
      ./components/fcron.nix
      ./components/msmtp.nix
      ./components/prometheus.nix
      ./components/openssh.nix
      ./components/sshkeys.nix
      ./components/smartd.nix
      ./components/sysstat.nix
      ./components/disthttpd.nix

      # !!! red-specific services - MOVE THESE TO red.nix? !!!
    ] ++ filesystems ++ std-filesystems;
  }

# ==============================================================================

# -- that's all, folks! --------------------------------------------------------

#  security.pki.certificateFiles = [ ./cert.pem ];
#  imports = [ ./overlays.nix ];
