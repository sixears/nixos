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
        (import ../hardware/awow-ak41.nix {
          inherit system bash-header;
          hostname       = "apparatus";
          domainname     = "sixears.co.uk";
          etherMac       = "00:e0:4c:5d:fc:17";
          stateVersion   = "22.11";
          systemPackages = pkgs: [
            (import ../pkgs/mkopenvpnconfs { inherit pkgs bash-header; })
          ];
          logicalCores   = 4;

          filesystems = [
            ../filesystems/boot.nix
            ../filesystems/std.nix
            ../filesystems/local.nix

            ../filesystems/archive6-a.nix
            ../filesystems/archive6-b.nix
            # nixpkgs on /local
            # ../filesystems/local-nixpkgs.nix

            ../filesystems/local-deluge.nix
          ];
          imports = pkgs: [

#            (import ../components/xserver.nix
#                    { inherit pkgs bash-header; dvorak=true; })

            ../components/hdcalm.nix
            ../components/mirrorfs.nix
            ../components/media.nix

            ../users/people/martyn.nix
            ../users/people/syncthing-martyn.nix

#      ../nginx-reverse-ssl.nix

            ../filesystems/ramdisk-cam.nix
            ../components/vsftpd.nix
            ../users/system/cam.nix
            ../components/cam-thttpd.nix

            ## When running the VPN tunnel, requests from dnscache to the
            ## outside world go via the tunnel; so the IP address doesn't appear
            ## as sixears, and so opendns won't filter.
            # ../dns-server-opendns.nix

            ../dns-server/cloudflare.nix
            ../components/openvpn.nix

            # create this with the mkopenvpnconfs script
            ../openvpn/new-york.nix

            ../components/deluged.nix
            ../components/deluge-killer.nix
            # host locks up every few days.  Maybe this will help.  2022-07-01
            ../components/daily-reboot.nix
          ];
        });
    }
