{
  nixpkgs-nixos-24-05-2024-06-20,
  bashHeader-2024-06-20,
  myPkgs-2024-06-20,
  nixos-system,
  ...
}:

let
  nixpkgs     = nixpkgs-nixos-24-05-2024-06-20;
  bashHeader  = bashHeader-2024-06-20;
  myPkgs      = myPkgs-2024-06-20;
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
        (import ../hardware/lenovo-carbon-x1-g12.nix {
          inherit system bash-header hlib;
          hostname     = "cargo";
          domainname   = "sixears.co.uk";
          # as ordained by lenovo
          etherMac     = "c4:c6:e6:1c:cf:f7";
          # as ordained by lenovo
          wifiMac      = "b0:47:e9:dc:95:42";
          stateVersion = "23.11";

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

            ## Try the latest kernel to help with logind/acpi failures & crashes
            ../components/kernel-latest.nix

##            (import ../components/xserver.nix {
##              inherit pkgs bash-header my-pkgs;
##              dvorak=true;
##            })
##            ../components/xserver-intel.nix
            ../components/greetd-sway.nix
            ../components/wayland.nix

            ../components/laptop.nix
            ../components/suspend.nix
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
            ../components/keyd.nix

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
            # ../users/people/jj.nix
            ../users/people/syncthing-martyn.nix
          ];
        });
    }
