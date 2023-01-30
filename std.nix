{ hostname, domainname, stateVersion, systemPackages, logicalCores, system
, bash-header
, boot      ? ./boot/efi.nix
, sshPubKey ? ./sshkeys + "/${hostname}.pub"
}:

{ lib, pkgs, ... }:

let
  filesystems   = [ ./filesystems/std.nix ];
  nixos-cfg     = import ./nixos-cfg { inherit pkgs system; };
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

    boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" "sd_mod" ];

    environment.systemPackages = systemPackages pkgs;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    environment.etc.nixos-cfg.source = "${nixos-cfg}";

    programs.sysdig.enable = true;

    # -- ssh -----------------------------------------------

    programs.ssh.knownHosts =
      { "localhost" = { publicKeyFile = sshPubKey; }; };

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

    imports = [
      ./remote-nixos-caches.nix
      boot
      (import ./networking.nix { inherit hostname domainname; })
      ./tz-gmt.nix
      (import ./nix-daemon.nix { inherit logicalCores; })
      ./keyboard.nix
      (import ./xserver.nix { inherit pkgs bash-header; })
      ./display.nix
      ./locate.nix
      ./acme.nix
      ./unfree.nix
      (import ./std-pkgs.nix { inherit pkgs bash-header; })
      ./sixears-hosts.nix
      ./fcron.nix
      ./msmtp.nix
      ./prometheus.nix
      ./openssh.nix
      ./sshkeys.nix
      ./smartd.nix
      ./sysstat.nix
      ./disthttpd.nix

      # !!! red-specific services - MOVE THESE TO red.nix? !!!
      ./laptop.nix
      ./printing.nix
      ./deluge-killer.nix
      # this doesn't easily co-exist with home-backup.nix
      ./local-home-backup.nix
    ] ++ filesystems;
  }

# ==============================================================================

# -- that's all, folks! --------------------------------------------------------

#  security.pki.certificateFiles = [ ./cert.pem ];
#  imports = [ ./overlays.nix ];
