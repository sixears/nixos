{ nixpkgs-nixos-23-05-2023-12-03
, bashHeader-2023-12-03
, myPkgs-2023-12-03
, nixos-system
, ...
}:

let
  nixpkgs    = nixpkgs-nixos-23-05-2023-12-03;
  bashHeader = bashHeader-2023-12-03;
  myPkgs     = myPkgs-2023-12-03;
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

      (import ../hardware/lenovo-s340-14api.nix {
        inherit system bash-header hlib;
        hostname     = "grain";
        domainname   = "sixears.co.uk";
        etherMac     = "9c:eb:e8:5e:18:ed";
        wifiMac      = "e4:aa:ca:ca:c9:dd";
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
                "/mnt/iron-man" = { device = "/dev/disk/by-uuid/003D-C764";
                                    options = [ "user" "noauto" "sync" ]; };
              };
          }
        ];

        imports = pkgs: [
          (import ../components/xserver.nix { inherit pkgs bash-header my-pkgs; })

          ../hardware/video/amd-gpu-crashfix.nix

          ../components/laptop.nix
          ../components/suspend.nix
          ../components/printing.nix
          # this doesn't easily co-exist with home-backup.nix
          ../components/local-home-backup.nix

          (import ../components/desktop.nix { inherit pkgs my-pkgs; })
          ../components/pulseaudio.nix
          ../components/scanning.nix

          ../components/haskell.nix
          ../components/pygame.nix

          ../users/people/xander.nix
          ../users/people/xander-pause.nix
          ../users/people/syncthing-xander.nix
          ../users/people/martyn.nix
          ../users/people/syncthing-martyn.nix
        ];
     });
   }

# ------------------------------------------------------------------------------
