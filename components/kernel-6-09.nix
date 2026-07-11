{ system, nixpkgs }:


let
#  nixpkgs-nixos-24-05-2024-06-20 = flake-inputs.nixpkgs-nixos-24-05-2024-06-20;
#  nixpkgs-nixos-24-05-2024-06-20-system =
#    nixpkgs-nixos-24-05-2024-06-20.legacyPackages.pkgs.${system};
  kernel =
#    builtins.trace nixpkgs.legacyPackages.${system}
    nixpkgs.legacyPackages.${system}.pkgs.linuxPackages_6_9;
in
  { boot.kernelPackages = nixpkgs.lib.mkForce kernel; }
