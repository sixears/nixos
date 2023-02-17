{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/3ae365af; # 2023-01-14
    hpkgs1.url  = github:sixears/hpkgs1/r0.0.8.0;
    bashHeader  = { url    = github:sixears/bash-header/5206b087;
                    inputs = { nixpkgs.follows = "nixpkgs"; }; };
  };

  outputs = { self, nixpkgs, hpkgs1, bashHeader, ... }:
    let
      nixos-system = { modules, system ? "x86_64-linux" }:
        let
          hpkgs = hpkgs1.packages.${system};
          bash-header = bashHeader.packages.${system}.bash-header;
        in
          nixpkgs.lib.nixosSystem { inherit system modules;
                                    # pass system through to modules & imports
                                    specialArgs =
                                      { inherit system bash-header;
                                        inherit (hpkgs) htinydns; };
                                  };

      # --------------------------------

    in {
      nixosConfigurations = {
        red =
          let
            system      = "x86_64-linux";
            bash-header = bashHeader.packages.${system}.bash-header;
            hpkgs       = hpkgs1.packages.${system};
          in
            nixos-system {
              inherit system;
              modules =
                [
                  { nixpkgs.overlays =
                      # to import each overlay individually
                      # [ (import ./overlays/shntool.nix) ];

                      # import everything from ./overlays/
                      let
                        lib = import ./lib.nix { plib = nixpkgs.lib; };
                      in
                        lib.importNixesNoArgs ./overlays;
                  }
                ] ++
                (import ./hardware/dell-xps-13-9310.nix {
                  inherit system bash-header;
                  hostname     = "red";
                  domainname   = "sixears.co.uk";
                  logicalCores = 12;
                  # generated by `hex-addr red.sixears.co.uk`
                  etherMac     = "72:65:64:2e:73:69";
                  wifiMac      = "Dell XPS 9315 Laptop Wireless";
                  stateVersion = "22.05";
                  systemPackages = pkgs: [
                    (import ./pkgs/mkopenvpnconfs { inherit pkgs bash-header; })
                    (import ./pkgs/wifi.nix { inherit pkgs; })

                    pkgs.shntool # see overlays/shntool.nix;
                                 # picks up overlay for 24-bit WAV patch

                    (import ./wifi-conns/bowery-secure-init.nix {inherit pkgs;})

                    (hpkgs.acct)
                  ];
                  filesystems = [
                    ./filesystems/efi.nix
                    ./filesystems/mobile-music.nix
                    ./filesystems/local.nix
                    ./filesystems/usb-sda.nix
                  ];
                  imports = pkgs: [
                    (import ./xserver.nix { inherit pkgs bash-header; })
                    ./xserver-dvorak.nix
                    ./xserver-intel.nix

                    ./laptop.nix
                    ./printing.nix
                    ./deluge-killer.nix
                    # this doesn't easily co-exist with home-backup.nix
                    ./local-home-backup.nix

                    ./desktop.nix
                    ./pulseaudio.nix
                    ./scanning.nix
                    ./openvpn.nix
                    ./nix-serve.nix
                    ./dns-server/cloudflare.nix

                    ./finbar.nix
                    ./keyboardio.nix

                    ./users/people/martyn.nix
                    ./users/people/syncthing-martyn.nix
                  ];
                });

          };
      };
    };
}

  # # # SoundWire
  # # Audio casting for Linux-Android https://georgielabs.net/
  # networking.firewall.allowedUDPPorts = [ 59010 59011 ];
  #
  # # # CFSSL - SSL Cert creation service
  # # https://blog.cloudflare.com/introducing-cfssl/
  # # https://github.com/cloudflare/cfssl
  # # enable the CFSSL CA api-server.
  # services.cfssl.enable = true;
  # services.cfssl.port   = 59998;
