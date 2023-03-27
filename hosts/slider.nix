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
        (import ../hardware/acer-aspire-one-721-3574.nix {
          inherit system bash-header;
          hostname     = "slider";
          domainname   = "sixears.co.uk";
          etherMac     = "20:6a:8a:24:87:26";
          wifiMac      = "18:f4:6a:a4:00:83";
          stateVersion = "22.05";
          boot = import ../boot/grub.nix { grub-device = "/dev/sda"; };
          systemPackages = pkgs: [
            pkgs.shntool # see overlays/shntool.nix;
                         # picks up overlay for 24-bit WAV patch

            (import ../wifi-conns/bowery-secure-init.nix {inherit pkgs;})
          ];
          filesystems = [
            ../filesystems/boot.nix
            ../filesystems/std.nix
            ../filesystems/local.nix

            ../filesystems/mobile-music.nix
          ];
          imports = pkgs: [
            (import ../components/xserver.nix
                    { inherit pkgs bash-header; dvorak=true; })

            ../components/laptop.nix

            ../components/desktop.nix
            ../components/pulseaudio.nix
            ../components/openvpn.nix
            ../dns-server/cloudflare.nix

            ../components/keyboardio.nix

            ../users/people/martyn.nix
            ../users/people/syncthing-martyn.nix
          ];
        });
    }

# ------------------------------------------------------------------------------
