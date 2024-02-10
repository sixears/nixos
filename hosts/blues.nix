{
  nixpkgs-nixos-23-05-2023-12-03,
  bashHeader-2023-12-03,
  myPkgs-2023-12-03,
  nixos-system,
  ...
}:

let
  nixpkgs     = nixpkgs-nixos-23-05-2023-12-03;
  bashHeader  = bashHeader-2023-12-03;
  myPkgs      = myPkgs-2023-12-03;
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

      (import ../hardware/lenovo-s540-13.nix {
        inherit system bash-header hlib;
        hostname     = "blues";
        domainname   = "sixears.co.uk";
        etherMac     = "9c:eb:e8:5e:18:2e";
        wifiMac      = "e4:aa:ea:cc:91:31";
        stateVersion = "19.03";
        systemPackages = pkgs: [
          (hpkgs.acct)
          (import ../pkgs/mkopenvpnconfs { inherit pkgs bash-header; })
          (import ../pkgs/lumix-copy.nix { inherit pkgs bash-header; })
        ];

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
          (import ../components/xserver.nix {inherit pkgs bash-header my-pkgs;})
          ../components/xserver-resolution-1920x1200.nix

          ../components/laptop.nix
          ../components/printing.nix
          # this doesn't easily co-exist with home-backup.nix
          ../components/local-home-backup.nix

            (import ../components/desktop.nix { inherit pkgs my-pkgs; })
          ../components/pulseaudio.nix
          ../components/scanning.nix

          ../components/finbar.nix
          ../components/openvpn.nix

          ../users/people/heather.nix
          ../users/people/heather-lumix-copy.nix
          ../users/people/heather-rsync-pictures.nix
          ../users/people/syncthing-heather.nix
          ../users/people/martyn.nix
          ../users/people/syncthing-martyn.nix
        ];
     });
   }
