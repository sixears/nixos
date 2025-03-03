{ nixpkgs-nixos-24-05-2024-06-20,bashHeader-2024-06-20,myPkgs-2024-06-20,nixos-system,... }:

let
  nixpkgs    = nixpkgs-nixos-24-05-2024-06-20;
  bashHeader = bashHeader-2024-06-20;
  myPkgs     = myPkgs-2024-06-20;
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
        (import ../hardware/awow-ak41.nix {
          inherit system bash-header hlib;
          hostname       = "apparatus";
          domainname     = "sixears.co.uk";
          etherMac       = "00:e0:4c:5d:fc:17";
          stateVersion   = "22.11";
          systemPackages = pkgs: [
            (import ../pkgs/mkopenvpnconfs { inherit pkgs bash-header; })
          ];
          logicalCores   = 4;

          filesystems = [
            ../filesystems/efi.nix
            ../filesystems/std.nix
            ../filesystems/local.nix

            ../filesystems/efi-b.nix
            ../filesystems/std-b.nix
            ../filesystems/local-b.nix
            # nixpkgs on /local
            ../filesystems/local-nixpkgs.nix

            ../filesystems/local-deluge.nix
          ];
          imports = pkgs: [

#            ../components/hdcalm.nix
            ../components/mirrorfs.nix
            ../components/media.nix

            ../users/people/martyn.nix
            ../users/people/syncthing-martyn.nix

#            ../filesystems/ramdisk-cam.nix
#            ../components/vsftpd.nix
#            ../users/system/cam.nix
#            ../components/cam-thttpd.nix

            ## When running the VPN tunnel, requests from dnscache to the
            ## outside world go via the tunnel; so the IP address doesn't appear
            ## as sixears, and so opendns won't filter.
            # ../dns-server-opendns.nix

            ../dns-server/cloudflare.nix
            ../components/openvpn.nix

            # create this with the mkopenvpnconfs script
            ../openvpn/new-york.nix

            ../components/deluge-killer.nix
            ../components/deluged.nix
            # host locks up every few days.  Maybe this will help.  2022-07-01
#            ../components/daily-reboot.nix

            ../users/system/media.group.nix
            ../components/sabnzbd.nix   # downloader
            ../components/radarr.nix    # movies
            ../components/sonarr.nix    # tv series
            ../components/prowlarr.nix  # indexer central
            ../components/bazarr.nix    # subtitles
            ../components/lidarr.nix    # music
          ];
        });
    }
