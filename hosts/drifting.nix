{
  nixpkgs-nixos-24-11-2025-03-24,
#  nixpkgs-nixos-24-05-2024-06-20,
#  bashHeader-2024-06-20,
  bashHeader-2024-12-11,
  myPkgs-2024-12-11,
#  myPkgs-2024-06-20,
  nixos-system,
  ...
}:

let
#  nixpkgs    = nixpkgs-nixos-24-05-2024-06-20;
  nixpkgs     = nixpkgs-nixos-24-11-2025-03-24;
  bashHeader  = bashHeader-2024-12-11;
#  bashHeader = bashHeader-2024-06-20;
#  myPkgs     = myPkgs-2024-06-20;
  myPkgs      = myPkgs-2024-12-11;

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

      (import ../hardware/dell-inspiron-7306.nix {
        inherit system bash-header hlib;
        hostname     = "drifting";
        domainname   = "sixears.co.uk";
        etherMac     = "64:72:69:66:74:69";
        wifiMac      = "9e:3f:86:01:96:a9";
        ip4addr      = "192.168.0.3";
        stateVersion = "19.03";
        systemPackages = pkgs: [
          (pkgs.ghc)
          (import ../pkgs/mkopenvpnconfs { inherit pkgs bash-header; })
          (import ../pkgs/lumix-copy.nix { inherit pkgs bash-header; })
        ];

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
                    device  = "/dev/disk/by-path/pci-0000:00:0d.0-usb-0:1.4:1.0-scsi-0:0:0:1-part1";
                    options = [ "user" "utf8" "umask=000" "noauto" "exec" "sync" ];
                  };
              };
          }
        ];

        imports = pkgs: [
          (import ../components/xserver.nix {inherit pkgs bash-header my-pkgs;})
          ../components/xserver-intel.nix

          ../components/laptop.nix
          ../components/printing.nix
          # this doesn't easily co-exist with home-backup.nix
          ../components/local-home-backup.nix

          # USB auto-mounting
          ../components/udisks2.nix

            (import ../components/desktop.nix { inherit pkgs my-pkgs; })
# as of 24.11, default is to use pipewire
#          ../components/pulseaudio.nix
          ../components/scanning.nix

          ../components/finbar.nix
          ../openvpn/no-autostart.nix

          ../components/cgroup-users.nix

          ../users/people/abigail.nix
          ../users/people/abigail-lumix-copy.nix
          ../users/people/syncthing-abigail.nix
          ../users/people/martyn.nix
          ../users/people/syncthing-martyn.nix
        ];
     });
   }
