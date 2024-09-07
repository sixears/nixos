# https://github.com/NixOS/nixpkgs/tags
{
  inputs = {
    nixpkgs-nixos-24-05-2024-06-20.url = github:NixOS/nixpkgs/938aa157;

###nixpkgs-nixos-23-11-2024-02-07.url = github:NixOS/nixpkgs/6832d0d9;
    # found checking out https://github.com/nixos/nixpkgs/, and/or running
    # `git pull` in there; and running
    # ```
    # git log origin/nixos-23.05 | grep ^Merge: | head -n 1 \
    #   | cut -d ' ' -f 2 | cut -c 1-8
    # ```
###    nixpkgs-nixos-23-05-2023-12-03.url = github:NixOS/nixpkgs/ea15d6f;

###    nixpkgs-2023-09-07.url = github:NixOS/nixpkgs/4f77ea639; # nixos-23.05
    nixpkgs-2023-03-24.url = github:NixOS/nixpkgs/07fb9ca; # master

#    nixos-22-11-release.url = github:NixOS/nixpkgs/f1b9cc2; # 22.11 release
    nixpkgs-2023-01-14.url = github:NixOS/nixpkgs/3ae365af; # master
    nixpkgs-2022-04-22.url = github:NixOS/nixpkgs/9887f024; # 22.05
    nixpkgs-2020-09-25.url = github:NixOS/nixpkgs/52075a82; # master
#    hpkgs1.url  = github:sixears/hpkgs1/r0.0.10.0;
    hpkgs1.url  = path:/home/martyn/src/hpkgs1;
    bashHeader-2024-06-20  = {
      url    = github:sixears/bash-header/c68d4608;
      inputs = { nixpkgs.follows = "nixpkgs-nixos-24-05-2024-06-20"; };
    };
###    bashHeader-2024-02-07  = {
###      url    = github:sixears/bash-header/c68d4608;
###      inputs = { nixpkgs.follows = "nixpkgs-nixos-23-11-2024-02-07"; };
###    };
###    bashHeader-2023-12-03  = {
###      url    = github:sixears/bash-header/e0c0096;
###      inputs = { nixpkgs.follows = "nixpkgs-nixos-23-05-2023-12-03"; };
###    };
###    bashHeader-2023-09-07  = {
###      url    = github:sixears/bash-header/5206b087;
###      inputs = { nixpkgs.follows = "nixpkgs-2023-09-07"; };
###    };
    bashHeader-2023-03-24  = {
      url    = github:sixears/bash-header/5206b087;
      inputs = { nixpkgs.follows = "nixpkgs-2023-03-24"; };
    };
    bashHeader-2023-01-14  = {
      url    = github:sixears/bash-header/5206b087;
      inputs = { nixpkgs.follows = "nixpkgs-2023-01-14"; };
    };
    myPkgs-2024-06-20      = {
      url    = github:sixears/nix-pkgs/r0.0.9.0;
      inputs = { nixpkgs.follows = "nixpkgs-nixos-24-05-2024-06-20"; };
    };
###    myPkgs-2024-02-07      = {
###      url    = github:sixears/nix-pkgs/r0.0.9.0;
###      inputs = { nixpkgs.follows = "nixpkgs-nixos-23-11-2024-02-07"; };
###    };
###    myPkgs-2023-12-03      = {
###      url    = github:sixears/nix-pkgs/r0.0.5.0;
###      inputs = { nixpkgs.follows = "nixpkgs-nixos-23-05-2023-12-03"; };
###    };
###    myPkgs-2023-09-07      = {
###      url    = github:sixears/nix-pkgs/r0.0.0.0;
###      inputs = { nixpkgs.follows = "nixpkgs-2023-09-07"; };
###    };
    myPkgs-2023-03-24      = {
      url    = github:sixears/nix-pkgs/r0.0.0.0;
      inputs = { nixpkgs.follows = "nixpkgs-2023-03-24"; };
    };
    myPkgs-2023-01-14      = {
      url    = github:sixears/nix-pkgs/r0.0.0.0;
      inputs = { nixpkgs.follows = "nixpkgs-2023-01-14"; };
    };
  };

  outputs = { self, hpkgs1
            , nixpkgs-nixos-24-05-2024-06-20, bashHeader-2024-06-20, myPkgs-2024-06-20
###            , nixpkgs-nixos-23-11-2024-02-07, bashHeader-2024-02-07, myPkgs-2024-02-07
###            , nixpkgs-nixos-23-05-2023-12-03, bashHeader-2023-12-03, myPkgs-2023-12-03
###            , nixpkgs-2023-09-07, bashHeader-2023-09-07, myPkgs-2023-09-07
            , nixpkgs-2023-03-24, bashHeader-2023-03-24, myPkgs-2023-03-24
            , nixpkgs-2023-01-14, bashHeader-2023-01-14, myPkgs-2023-01-14
            , nixpkgs-2022-04-22 # for mythtv
            , nixpkgs-2020-09-25 # for plex
            , ... }:
    let
      nixos-system = { nixpkgs, bashHeader, myPkgs, modules
                     , system ? "x86_64-linux" }:
        let
          hpkgs = hpkgs1.packages.${system};
          hlib  = hpkgs1.lib.${system};
          bash-header = bashHeader.packages.${system}.bash-header;
          my-pkgs     = myPkgs.packages.${system};
        in
          nixpkgs.lib.nixosSystem { inherit system;
                                    modules =
                                      modules { inherit system bash-header
                                                        hlib my-pkgs hpkgs; };
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
          lib = import ./lib.nix { plib = nixpkgs-nixos-24-05-2024-06-20.lib; };
          by-name =
            lib.importNixesByName ./hosts {
              inherit
                nixos-system

                nixpkgs-nixos-24-05-2024-06-20
                bashHeader-2024-06-20
                myPkgs-2024-06-20

###                nixpkgs-nixos-23-11-2024-02-07
###                bashHeader-2024-02-07
###                myPkgs-2024-02-07

###                nixpkgs-nixos-23-05-2023-12-03
###                bashHeader-2023-12-03
###                myPkgs-2023-12-03

###                nixpkgs-2023-09-07
###                bashHeader-2023-09-07
###                myPkgs-2023-09-07

                nixpkgs-2023-03-24
                bashHeader-2023-03-24
                myPkgs-2023-03-24

                nixpkgs-2023-01-14
                bashHeader-2023-01-14
                myPkgs-2023-01-14

                nixpkgs-2022-04-22
                nixpkgs-2020-09-25
              ;

#              nixpkgs-2023-01-14-url = "github:NixOS/nixpkgs=3ae365af";
#              nixpkgs-2023-09-07-url = "github:NixOS/nixpkgs=4f77ea6";
            };
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
