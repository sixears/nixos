{
  description = "provide a podcast feed for some mp3 files in some dirs";

  inputs = {
    nixpkgs.url     = github:nixos/nixpkgs/be6da377; # nixos-22.05 2022-06-29
    flake-utils.url = github:numtide/flake-utils/c0e246b9;
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        defaultPackage =
          import ./default.nix { nixpkgs = nixpkgs.legacyPackages.${system};
                                 inherit system; };
      }
    );

}
