{ nixpkgs-2023-01-14, bashHeader-2023-01-14, nixos-system, ... }:

let
  nixpkgs    = nixpkgs-2023-01-14;
  bashHeader = bashHeader-2023-01-14;
in
  nixos-system
    {
      inherit nixpkgs bashHeader;
      modules = { system, bash-header, hpkgs, hlib }:
        [
          { nixpkgs.overlays =
              # to import each overlay individually
              # [ (import ../overlays/shntool.nix) ];

              # import everything from ../overlays/
              let
                lib = import ../lib.nix { plib = nixpkgs.lib; };
              in
                lib.importNixesNoArgs ../overlays;
          }
        ] ++

      (import ../hardware/lenovo-s540-13.nix {
        inherit system bash-header;
        hostname     = "blues";
        domainname   = "sixears.co.uk";
        etherMac     = "9c:eb:e8:5e:18:2e";
        wifiMac      = "e4:aa:ea:cc:91:31";
        stateVersion = "19.03";
        systemPackages = pkgs: [ (hpkgs.acct) ];

        filesystems = [
          ../filesystems/std.nix
          ../filesystems/efi.nix
          ../filesystems/mobile-music.nix
          ../filesystems/local.nix
          ../filesystems/usb-sda.nix

          {
            fileSystems =
              {
                "/mnt/sdcard" =
                  {
                    device = "/dev/disk/by-path/pci-0000:03:00.3-usb-0:1.4:1.0-scsi-0:0:0:1-part1";
                    options = [ "user" "utf8" "umask=000" "noauto" "exec" "sync" ];
                  };
              };
          }
        ];

        imports = pkgs: [
          (import ../components/xserver.nix { inherit pkgs bash-header; })

          ../components/laptop.nix
          ../components/printing.nix
          # this doesn't easily co-exist with home-backup.nix
          ../components/local-home-backup.nix

          ../components/desktop.nix
          ../components/pulseaudio.nix
          ../components/scanning.nix

          ../components/finbar.nix

          ../users/people/heather.nix
          ../users/people/syncthing-heather.nix
          ../users/people/martyn.nix
          ../users/people/syncthing-martyn.nix
        ];
     });
   }
