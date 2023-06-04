{ nixpkgs-2023-01-14,bashHeader-2023-01-14,myPkgs-2023-01-14,nixos-system,... }:

let
  nixpkgs    = nixpkgs-2023-01-14;
  bashHeader = bashHeader-2023-01-14;
  myPkgs     = myPkgs-2023-01-14;
in
  nixos-system
    {
      inherit nixpkgs bashHeader myPkgs;
      modules = { system, bash-header, my-pkgs, hpkgs, hlib }:
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

      (import ../hardware/lenovo-yoga-s730-13.nix {
        inherit system bash-header;
        hostname     = "trance";
        domainname   = "sixears.co.uk";
        etherMac     = "00:e0:4c:68:04:ab";
        wifiMac      = "Lenovo Yoga S730 Laptop Wireless";
        stateVersion = "21.03";
        systemPackages = pkgs: [ (hpkgs.acct) ];

        filesystems = [
          ../filesystems/std.nix
          ../filesystems/efi.nix
          ../filesystems/mobile-music.nix
          ../filesystems/local.nix
          ../filesystems/usb-sda.nix

          # nixpkgs on /local
          ../filesystems/local-nixpkgs.nix

          {
            fileSystems =
              {
                "/mnt/sdcard" =
                  {
                    device = "/dev/disk/by-path/pci-0000:39:00.0-usb-0:1.4:1.0-scsi-0:0:0:1-part1";
                    options = [ "user" "utf8" "umask=000"
                                "noauto" "exec" "sync" ];
                  };
              };
          }
        ];

        imports = pkgs: [
          (import ../components/xserver.nix { inherit pkgs bash-header my-pkgs; })

          ../components/laptop.nix
          ../components/printing.nix
          # this doesn't easily co-exist with home-backup.nix
          ../components/local-home-backup.nix

          ../components/desktop.nix
          ../components/pulseaudio.nix
          ../components/scanning.nix

          ../components/steam.nix

          ../users/people/jj.nix
          ../users/people/jj-pause.nix
          ../users/people/syncthing-jj.nix

          ../users/people/martyn.nix
          ../users/people/syncthing-martyn.nix
        ];
     });
   }

# ------------------------------------------------------------------------------
