# After updating, test:
#  -) plex
#  -) mythtv
#  -) podcasts
#  -) gitit
{ nixpkgs-nixos-24-11-2024-12-11, bashHeader-2024-12-11, myPkgs-2024-12-11
, nixpkgs-2020-09-25
, nixpkgs-2022-04-22
, nixos-system, ... }:

let
  nixpkgs    = nixpkgs-nixos-24-11-2024-12-11;
  bashHeader = bashHeader-2024-12-11;
  myPkgs     = myPkgs-2024-12-11;
in
  nixos-system
    {
      inherit nixpkgs bashHeader myPkgs;
      modules = { system, bash-header, my-pkgs, hpkgs, hlib }:
        [
          { nixpkgs.overlays =
              # to import each overlay individually
              # [ (import ../overlays/shntool.nix) ];

              let
                lib                  =
                  import ../lib.nix { plib = nixpkgs.lib; };
                allowUnfreePredicate =
                  import ../components/unfree-predicate.nix { pkgs = nixpkgs; };
                r2020-09-25 =
                  import "${nixpkgs-2020-09-25}" {
                    inherit system;
                    config = { inherit allowUnfreePredicate; };
                  };
                r2022-04-22 =
                  import "${nixpkgs-2022-04-22}" {
                    inherit system;
                    config = { inherit allowUnfreePredicate; };
                  };
              in
                # import everything from ../overlays/
                lib.importNixesNoArgs ../overlays
            ++ [(final: prev: {
                   inherit (r2020-09-25) plex;   # v1.20
#                   inherit (r2022-04-22) mythtv; # v31.0
                 }
                )];
          }
        ] ++
        (import ../hardware/generic.nix {
          inherit system bash-header hlib;
          hostname     = "night";
          domainname   = "sixears.co.uk";
          logicalCores = 16;
          # taken from the card
          etherMac = "04:d9:f5:f9:db:cc";
          stateVersion = "22.05";
          virtualization = ../virtualization/amd.nix;
          nvme0 = true;
          systemPackages = pkgs: [
          ];
          filesystems = [
            # nvme "Falcon" Sabrent 477GiB/512Gb Rocket M.2
            ../filesystems/efi-x-primary.nix
            ../filesystems/std-x-primary.nix
            ../filesystems/local-x-primary.nix

            # 2.5" SATA SSD "Black Panther" Crucial Micron 466GiB/500Gb
            ../filesystems/efi-b.nix
            ../filesystems/std-b.nix
            ../filesystems/local-b.nix

            # "Quicksilver" Toshiba MG 7.28TiB / 8Tb
            ../filesystems/efi-c.nix
            ../filesystems/std-c.nix
            ../filesystems/local-c.nix
            ../filesystems/archive0-a.nix

            # "Hawkeye" Toshiba N300 HDWN180 7.28TiB / 8Tb
            ../filesystems/archive1-b.nix

            # "Quicksilver" Toshiba MG 7.28TiB / 8Tb
            ../filesystems/archive0-b.nix
            ../filesystems/efi-d.nix
            ../filesystems/std-d.nix
            ../filesystems/local-d.nix

            # Seagate ST8000 7.28TiB / 8Tb
#            ../filesystems/archive3-b.nix

            # Toshiba N300 HDWN180 7.28TiB / 8Tb
            ../filesystems/archive1-a.nix

            # Seagate ST8000 7.28TiB / 8Tb
            ../filesystems/archive3-a.nix

            # nixpkgs on /local
            ../filesystems/local-nixpkgs.nix

            # desperate overflow management
            ../filesystems/local-prometheus.nix
            ../filesystems/local-plex.nix
          ];
          imports = pkgs: [
            ../dns-server/opendns.nix

            # support GeForce GT 710
            ../hardware/video/nvidia470.nix
            ../hardware/video/nvidia.nix
            ../hardware/sata/ahci.nix
            ../hardware/sata/xhci-pci.nix
            ../hardware/sata/ehci-pci.nix

            (import ../components/xserver.nix { inherit pkgs bash-header my-pkgs; })
            ../components/hdcalm.nix
            ../components/mirrorfs.nix

            ../components/home-backup.nix

            ../components/media.nix
            ../components/get_iplayer.nix
            ../components/plex.nix   # should be v1.20
            ../components/mythtv.nix # should be v31.0
            ../components/jellyfin.nix
            # Pre-24.11
            # ../components/tvheadend.nix

            ../components/podcaster.nix
            ../components/gitit.nix
            ../components/nix-serve.nix
            ../components/cam-proxy.nix
            # Pre-24.11
            # ../components/pulseaudio.nix

            ../users/people/martyn.nix
            ../users/people/fletch.nix
            ../users/people/syncthing-martyn.nix
            ../users/people/syncthing-heather.nix
            ../users/people/syncthing-abigail.nix
            ../users/people/syncthing-xander.nix
            ../users/people/syncthing-jj.nix

            ../users/system/racereplay.nix
          ];
        });
    }
