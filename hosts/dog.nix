{
  nixpkgs-2023-09-07,
  bashHeader-2023-09-07,
  myPkgs-2023-09-07,
  nixos-system,
  ...
}:

let
  nixpkgs     = nixpkgs-2023-09-07;
  bashHeader  = bashHeader-2023-09-07;
  myPkgs      = myPkgs-2023-09-07;
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
        (import ../hardware/generic.nix {
          inherit system bash-header hlib;
          hostname     = "dog";
          domainname   = "sixears.co.uk";
          logicalCores = 16;
          # taken from the card
          etherMac = "04:92:26:da:00:ca";
          stateVersion = "22.05";
          virtualization = ../virtualization/amd.nix;
          nvme0 = true;
          systemPackages = pkgs: [
            (import ../pkgs/mkopenvpnconfs { inherit pkgs bash-header; })

            pkgs.shntool # see overlays/shntool.nix;
                         # picks up overlay for 24-bit WAV patch

            (hpkgs.acct)
          ];
          filesystems = [
            # nvme0n1
            ../filesystems/efi-a.nix
            ../filesystems/std-a.nix
            ../filesystems/local.nix
            # 120GB SSD
            ../filesystems/efi-b.nix
            ../filesystems/std-b-nonix.nix
            ../filesystems/data.nix
            # 4TB HDD
            ../filesystems/efi-c.nix
            ../filesystems/std-c.nix
            ../filesystems/archive5-a.nix
            # HGST 4TB HDD
            ../filesystems/efi-d.nix
            ../filesystems/std-d.nix
            ../filesystems/archive5-b.nix

            # Toshiba 3TB HDD (Hulk)
            ../filesystems/archive4-a.nix
            # Toshiba 3TB HDD (Iron Man)
            ../filesystems/archive4-b.nix
            # Hitachi Deskstar 3TB HDD (Thor)
            ../filesystems/archive2-a.nix
            # Hitachi Deskstar 3TB HDD (Captain America)
            ../filesystems/archive2-b.nix

            # removable discs
            ../filesystems/removable-mxphone.nix
            ../filesystems/removable-hxphone.nix
            # nixpkgs on /local
            ../filesystems/local-nixpkgs.nix
          ];
          imports = pkgs: [

            ../dns-server/cloudflare.nix

            # support GeForce GT 710
            ../hardware/video/nvidia470.nix
            ../hardware/video/nvidia.nix
            ../hardware/sata/ahci.nix
            ../hardware/sata/xhci-pci.nix
            # sg needed for makemkv to recognize the CDRom/BluRay
            ../hardware/scsi/sg.nix

            (import ../components/xserver.nix
                     { inherit pkgs bash-header my-pkgs; dvorak=true; })

            ../components/scanning.nix
            ../components/hdcalm.nix
            ../components/pulseaudio.nix
            ../components/pulseaudio-udev.nix
            ../components/thttpd.nix

            ../components/gdddns.nix # GoDaddy DNS updater (with our public IP)
            ../components/mirrorfs.nix
            ../components/local-home-backup.nix
            ../components/vsftpd.nix
            ../components/openvpn.nix
            ../components/nix-serve.nix

            ../components/adb.nix # Android Debug Bridge
            ../components/nixos-head-auto-update.nix
            # ../components/rsync-deluge.nix
            ../components/rsync-nixpkgs.nix
            # ../components/dnsmasq.nix
            # ../components/pygame.nix
            # ../components/subversion-httpd.nix
            # ../components/tmpwww.nix
            # ../components/virtualbox.nix

            ../components/media.nix
            ../components/finbar.nix

            # for rtunnel
            ../users/people/abigail.nix
            ../users/people/martyn.nix
            ../users/people/syncthing-martyn.nix
            ../users/people/fletch.nix

            # ../components/minio.nix
            # (import ../users/system/cam.nix { inherit pkgs hlib hpkgs; })
            # ../components/docker.nix
          ];
        });
    }

# ------------------------------------------------------------------------------

