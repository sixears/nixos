{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/3ae365af; # 2023-01-14
    hpkgs1.url  = github:sixears/hpkgs1/r0.0.8.0;
    bash-header = { url    = github:sixears/bash-header/5206b087;
                    inputs = { nixpkgs.follows = "nixpkgs"; }; };
  };
#  inputs.home-manager.url = github:nix-community/home-manager;

  outputs = { self, nixpkgs, hpkgs1, bash-header, ... }:
    let
      settings-i915 = { pkgs, ... }:
        {
        # we need linux 5.19+ for sound support, but with 5.19.8 at least;
        # the i915 crashes the display
        boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
        # https://wiki.archlinux.org/title/Dell_XPS_13_(9310)#Random_Hangs_on_i915_with_kernel
        # Random Hangs on i915 with kernel
        #
        #   Occasionally the laptop hangs when running the i915 Linux
        #   driver.
        #   This results in an occasional visual delay to keyboard inputs
        #   and makes the system appear to be crashing.
        #
        # The bug report for this issue can be found here:
        # https://gitlab.freedesktop.org/drm/intel/-/issues/3496
        #
        # Set panel self refresh to off in the kernel parameters:
        # i915.enable_psr=0 i915.enable_fbc=1.
        boot.kernelParams = [ "i915.enable_psr=0" "i915.enable_fbc=1" ];
      };

      settings-nvme0 = { ... }: {
        services.smartd.devices =
          [ { device="/dev/nvme0"; options = "-d nvme -W 0,70,75"; } ];

        boot.initrd.availableKernelModules = [ "nvme" ];
      };

      settings-intel = { ... }: {
        boot.kernelModules = [ "kvm-intel" ];
      };

      settings-laptop = { ... }: {
        powerManagement.cpuFreqGovernor = "powersave";
      };

      settingses-dell-xps-13-9310 =
        [ settings-i915 settings-intel settings-laptop settings-nvme0 ];

      dell-xps-13-9310 = { hostname, domainname, stateVersion, logicalCores
                         , etherMac, wifiMac, systemPackages, system
                         , filesystems, imports }:
        settingses-dell-xps-13-9310 ++ [
          (import ./ethernet.nix { inherit etherMac; })
          (import ./wifi.nix     { inherit wifiMac; })
          (import ./std.nix      { inherit hostname domainname stateVersion
                                           logicalCores systemPackages system
                                           bash-header filesystems imports;
                                 })
        ];

      nixos-system = { modules, system ? "x86_64-linux" }:
        let
          hpkgs = hpkgs1.packages.${system};
        in
          nixpkgs.lib.nixosSystem { inherit system modules;
                                    # pass system through to modules & imports
                                    specialArgs =
                                      { inherit system bash-header;
                                        inherit (hpkgs) htinydns; };
                                  };
    in {
      nixosConfigurations = {
        red =
          let
            system = "x86_64-linux";
          in
            nixos-system {
              inherit system;
              modules =
                [
                  { nixpkgs.overlays =
                      # to import each overlay individually
                      # [ (import ./overlays/shntool.nix) ];

                      # import everything from ./overlays/
                      let
                        lib = import ./lib.nix { plib = nixpkgs.lib; };
                      in
                        lib.importNixesNoArgs ./overlays;
                  }
                ] ++
                (dell-xps-13-9310 {
                  inherit system;
                  hostname     = "red";
                  domainname   = "sixears.co.uk";
                  logicalCores = 12;
                  # generated by `hex-addr red.sixears.co.uk`
                  etherMac     = "72:65:64:2e:73:69";
                  wifiMac      = "Dell XPS 9315 Laptop Wireless";
                  stateVersion = "22.05";
                  systemPackages = pkgs: [
                    (import ./pkgs/mkopenvpnconfs { inherit pkgs bash-header; })
                    (import ./pkgs/wifi.nix { inherit pkgs; })

                    pkgs.shntool # picks up overlay for 24-bit WAV patch

                    (import ./wifi-conns/bowery-secure-init.nix {inherit pkgs;})

                  ];
                  filesystems = [
                    ./filesystems/efi.nix
                    ./filesystems/mobile-music.nix
                    ./filesystems/local.nix
                    ./filesystems/usb-sda.nix
                  ];
                  imports = pkgs: [
                    (import ./xserver.nix { inherit pkgs bash-header; })
                    ./xserver-dvorak.nix
                    ./xserver-intel.nix

                    ./laptop.nix
                    ./printing.nix
                    ./deluge-killer.nix
                    # this doesn't easily co-exist with home-backup.nix
                    ./local-home-backup.nix

                    ./desktop.nix
                    ./pulseaudio.nix
                    ./scanning.nix
                    ./openvpn.nix
                    ./nix-serve.nix
                    ./dns-server/cloudflare.nix

                    ./finbar.nix
                    ./keyboardio.nix

                    ./users/people/martyn.nix
                    ./users/people/syncthing-martyn.nix
                  ];
                });

          };
      };
    };
}

#X# { config ? import ./nullcfg.nix, lib, options, modulesPath, pkgs, specialArgs ? {} }:
#X#   {
#X#     imports =
#X#       [
#X#
#X#
#X#
#X# #        ../containers-podcaster.nix
#X# #        ../bluetooth.nix
#X#
#X#
#X# #        ../tmpwww.nix
#X# #        ../virtualbox.nix
#X#
#X#
#X# #        ../docker.nix
#X#
#X#
#X#
#X#         ../fwupd.nix
#X#       ];
#X#
#X#     fileSystems =
#X#       {
#X#         "/mnt/sdcard" =
#X#           {
#X#             device = "/dev/disk/by-path/pci-0000:39:00.0-usb-0:1.4:1.0-scsi-0:0:0:1-part1";
#X#             options = [ "user" "utf8" "umask=000" "noauto" "exec" "sync" ];
#X#           };
#X#       };
#X#
#X#
#X#     # SoundWire
#X# #    networking.firewall.allowedUDPPorts = [ 59010 59011 ];
#X#
#X#     # enable the CFSSL CA api-server.
#X#     services.cfssl.enable = true;
#X#     services.cfssl.port   = 59998;
#X#   }
#X#
