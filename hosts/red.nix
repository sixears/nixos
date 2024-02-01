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
        (import ../hardware/dell-xps-13-9310.nix {
          inherit system bash-header hlib;
          hostname     = "red";
          domainname   = "sixears.co.uk";
          # generated by `hex-addr red.sixears.co.uk`
          etherMac     = "72:65:64:2e:73:69";
          wifiMac      = "Dell XPS 9315 Laptop Wireless";
          stateVersion = "22.05";

          systemPackages = pkgs: [
            (import ../pkgs/mkopenvpnconfs { inherit pkgs bash-header; })

            pkgs.shntool # see overlays/shntool.nix;
                         # picks up overlay for 24-bit WAV patch

            (import ../wifi-conns/bowery-secure-init.nix {inherit pkgs;})

            (hpkgs.acct)
          ];
          filesystems = [
            ../filesystems/std.nix
            ../filesystems/efi.nix
            ../filesystems/mobile-music.nix
            ../filesystems/local.nix
            ../filesystems/usb-sda.nix
          ];
          imports = pkgs: [
##            (import ../components/xserver.nix {
##              inherit pkgs bash-header my-pkgs;
##              dvorak=true;
##            })
##            ../components/xserver-intel.nix
            ../components/greetd-sway.nix
            ../components/wayland.nix

            ../components/laptop.nix
            ../components/printing.nix
            ../components/deluge-killer.nix
            # this doesn't easily co-exist with home-backup.nix
            ../components/local-home-backup.nix

            (import ../components/desktop.nix { inherit pkgs my-pkgs; })
            ../components/pulseaudio.nix
            ../components/scanning.nix
            ../components/openvpn.nix
            ../components/nix-serve.nix
            ../dns-server/cloudflare.nix
#            ../components/zsa.nix

# not compiling for now, this is hard to do on a fresh install
#            ../components/finbar.nix
            ../components/keyboardio.nix

#           this crashes when it goes into auto-suspend :-(
#            (import ../components/suspend-then-hibernate.nix {
#              suspend-hibernate-time  = "1h";
#              idle-suspend-time       = "30m";
#            })

            (import ../components/hibernate.nix { idle-suspend-time = "30m"; })

            ../users/people/martyn.nix
            ../users/people/syncthing-martyn.nix
          ];
        });
    }
