{
  description = "Create openvpn configurations";

  inputs = {
    nixpkgs.url     = github:nixos/nixpkgs/3ae365af; # 2023-01-14
    flake-utils.url = github:numtide/flake-utils/c0e246b9;
    bash-header     = { url = github:sixears/bash-header/5206b087;
                        inputs.nixpkgs.follows = "nixpkgs";        };
  };

  outputs = { self, nixpkgs, flake-utils, bash-header }:
    flake-utils.lib.eachDefaultSystem (system:
      rec {
        packages.mkopenvpnconfs =
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
            import ./default.nix { inherit pkgs bash-header; };

        defaultPackage = packages.mkopenvpnconfs;
      });
}
