{...}:

{
  boot.kernelPatches = [ {
    name  = "acpi-debug";
    patch = null;
    extraConfig = ''
      ACPI_DEBUG y
    '';
  } ];
}
