{
  nixpkgs-nixos-25-05-2025-08-15,
  bashHeader-2025-08-15,
  myPkgs-2025-08-15,
  nixos-system,
  ...
}:

let
  nixpkgs     = nixpkgs-nixos-25-05-2025-08-15;
  bashHeader  = bashHeader-2025-08-15;
  myPkgs      = myPkgs-2025-08-15;
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

      (import ../hardware/lenovo-thinkpad-e14gen7.nix {
        inherit system bash-header hlib;
        hostname     = "incubus";
        domainname   = "sixears.co.uk";
        etherMac     = "a8:2b:dd:45:76:8d";
        # wifiMac      = "e4:aa:ea:cc:91:31";
        stateVersion = "25.05";
        systemPackages = pkgs: [
          # (hpkgs.acct)
          (import ../pkgs/mkopenvpnconfs { inherit pkgs bash-header; })
          (import ../pkgs/lumix-copy.nix { inherit pkgs bash-header; })
        ];

        filesystems = [
          ../filesystems/std-noswap.nix
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
          (import ../components/xserver.nix {inherit pkgs bash-header my-pkgs;})
          ../components/xserver-resolution-1920x1200.nix

          ../components/laptop.nix
          ../components/printing.nix
          # this doesn't easily co-exist with home-backup.nix
          ../components/local-home-backup.nix

            (import ../components/desktop.nix { inherit pkgs my-pkgs; })
# as of 24.11, default is to use pipewire
##          ../components/pulseaudio.nix
          ../components/scanning.nix

          ../components/finbar.nix
          ../openvpn/no-autostart.nix
          ../components/zram.nix

          ../users/people/heather.nix
          ../users/people/heather-lumix-copy.nix
          ../users/people/heather-rsync-pictures.nix
          ../users/people/syncthing-heather.nix
          ../users/people/martyn.nix
          ../users/people/syncthing-martyn.nix
        ];
     });
   }
