{ system, nixpkgs }:


let
  kernel = nixpkgs.legacyPackages.${system}.pkgs.linuxPackages_6_8;
in
  { boot.kernelPackages = nixpkgs.lib.mkForce kernel; }
