{ system, nixpkgs }:


let
  kernel = nixpkgs.legacyPackages.${system}.pkgs.linuxPackages_6_12.override {
    extraConfig = ''
      ACPI_DEBUG y
    '';
    };
in
  { boot.kernelPackages = nixpkgs.lib.mkForce kernel; }
