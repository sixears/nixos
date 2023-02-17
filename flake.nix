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
          nixpkgs.lib.nixosSystem { inherit system;
                                    modules =
                                      modules { inherit system
                                                        bash-header hpkgs; };
                                    # pass system through to modules & imports
                                    specialArgs =
                                      { inherit system bash-header;
                                        inherit (hpkgs) htinydns; };
                                  };

      # --------------------------------

    in {
      nixosConfigurations = {
        red = (import ./hosts/red.nix) { inherit nixpkgs nixos-system; };
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
