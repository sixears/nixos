{
  inputs = {
    nixos-22-11-release.url = github:NixOS/nixpkgs/f1b9cc2; # 22.11 release
    nixpkgs-2023-01-14.url = github:NixOS/nixpkgs/3ae365af; # master
    nixpkgs-2022-04-22.url = github:NixOS/nixpkgs/9887f024; # 22.05
    nixpkgs-2020-09-25.url = github:NixOS/nixpkgs/52075a82; # master
    hpkgs1.url  = github:sixears/hpkgs1/r0.0.10.0;
#    hpkgs1.url  = path:/home/martyn/src/hpkgs1;
    bashHeader-2023-01-14  = {
      url    = github:sixears/bash-header/5206b087;
      inputs = { nixpkgs.follows = "nixpkgs-2023-01-14"; };
    };
    bashHeader-22-11-release  = {
      url    = github:sixears/bash-header/5206b087;
      inputs = { nixpkgs.follows = "nixos-22-11-release"; };
    };
  };

  outputs = { self, hpkgs1
            , nixos-22-11-release, bashHeader-22-11-release
            , nixpkgs-2023-01-14, bashHeader-2023-01-14
            , nixpkgs-2022-04-22 # for mythtv
            , nixpkgs-2020-09-25 # for plex
            , ... }:
    let
      nixos-system = { nixpkgs, bashHeader, modules, system ? "x86_64-linux" }:
        let
          hpkgs = hpkgs1.packages.${system};
          hlib  = hpkgs1.lib.${system};
          bash-header = bashHeader.packages.${system}.bash-header;
        in
          nixpkgs.lib.nixosSystem { inherit system;
                                    modules =
                                      modules { inherit system bash-header
                                                        hlib hpkgs; };
                                    # pass system through to modules & imports
                                    specialArgs =
                                      { inherit system bash-header hlib;
                                        inherit (hpkgs) htinydns; };
                                  };

      # --------------------------------

    in {
      nixosConfigurations =
        let
          # import each hosts/<name>.nix as <name>
          lib = import ./lib.nix { plib = nixpkgs-2023-01-14.lib; };
          by-name =
            lib.importNixesByName ./hosts { inherit nixos-system
                                                    nixos-22-11-release
                                                    bashHeader-22-11-release
                                                    nixpkgs-2023-01-14
                                                    bashHeader-2023-01-14
                                                    nixpkgs-2022-04-22
                                                    nixpkgs-2020-09-25; };
        in
          by-name;
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
