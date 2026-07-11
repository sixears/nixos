{ boot, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_8.override {
  kernelPatches = [];
  extraConfig = ''
    ACPI_DEBUG y
  '';
});
}
