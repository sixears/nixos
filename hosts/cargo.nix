{
  nixpkgs-nixos-26-05-2026-06-26,
#  nixpkgs-nixos-25-05-2025-08-15,
  bashHeader-2025-10-21,
  myPkgs-2024-12-11,
  # needed for kernel 6.9
  nixpkgs-nixos-24-05-2024-06-20,
  nixos-system,
  ...
}:

let
  nixpkgs     = nixpkgs-nixos-26-05-2026-06-26;
#  nixpkgs     = nixpkgs-nixos-25-05-2025-08-15;
  bashHeader  = bashHeader-2025-10-21;
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
        (import ../hardware/lenovo-carbon-x1-g12.nix {
          inherit system bash-header hlib;
          hostname     = "cargo";
          domainname   = "sixears.co.uk";
          # as ordained by lenovo
          etherMac     = "c4:c6:e6:1c:cf:f7";
          # as ordained by lenovo
          wifiMac      = "b0:47:e9:dc:95:42";
          ip4addr      = "192.168.0.10";
          stateVersion = "23.11";

          systemPackages = pkgs: [
            (import ../pkgs/mkopenvpnconfs { inherit pkgs bash-header; })

            pkgs.shntool # see overlays/shntool.nix;
                         # picks up overlay for 24-bit WAV patch

            (import ../wifi-conns/bowery-secure-init.nix {inherit pkgs;})

            (hpkgs.acct)

##            (import ../pkgs/openvpn { inherit pkgs system; })
          ];
          filesystems = [
            ../filesystems/std.nix
            ../filesystems/efi.nix
            ../filesystems/mobile-music.nix
            ../filesystems/local.nix
            ../filesystems/usb-sda.nix
          ];
          imports = pkgs: [

            ## 6.12 in nixos-24.11 causes lockup at suspend
#            ../components/kernel-latest.nix

##          wifi fails with 6.9
##            (import ../components/kernel-6-09.nix
##              { inherit system; nixpkgs = nixpkgs-nixos-24-05-2024-06-20; })

##            (import ../components/kernel-6-12.nix
##              { inherit system; nixpkgs = nixpkgs-nixos-24-05-2024-06-20; })
##            (import ../components/kernel-6-12.nix
##              { inherit system nixpkgs; })
              ../components/kernel-acpi-debug.nix

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
##            ../components/deluge-killer.nix
            # this doesn't easily co-exist with home-backup.nix
            ../components/local-home-backup.nix

            (import ../components/desktop.nix { inherit pkgs my-pkgs; })
# as of 24.11, default is to use pipewire
##            ../components/pulseaudio.nix
            ../components/scanning.nix
##            ../openvpn/no-autostart.nix
            (import ../pkgs/openvpn.nix { inherit pkgs system; })
            # 2025-11-22 - we don't need this, we use sudo systemctl start openvpn-*
            # ../components/private-internet-access.nix
            ../components/nix-serve.nix
            ../dns-server/cloudflare.nix
#            ../components/zsa.nix
#            ../components/keyd.nix

# not compiling for now, this is hard to do on a fresh install
#            ../components/finbar.nix
            ../components/keyboardio.nix

            ## ../components/cgroup-users.nix
            # ../components/fprint.nix
            ../components/fido.nix

            # iphone mount
            ../components/usbmuxd.nix

#           this crashes when it goes into auto-suspend :-(
#            (import ../components/suspend-then-hibernate.nix {
#              suspend-hibernate-time  = "1h";
#              idle-suspend-time       = "30m";
#            })
# embed this in kernel-x-xx.nix
#            ../components/acpi-debugging.nix

            (import ../components/acpi-wakeup-manager.nix { inherit pkgs; })

            (import ../components/hibernate.nix { idle-suspend-time = "30m"; })

            ../users/people/martyn.nix
            # ../users/people/jj.nix
            ../users/people/syncthing-martyn.nix
          ];
        });
    }
