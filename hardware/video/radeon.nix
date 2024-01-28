# https://nixos.wiki/wiki/AMD_GPU
# https://nixos.org/manual/nixos/unstable/index.html#sec-gpu-accel-vulkan-amd
{ pkgs, lib, ... }:

{
  boot.kernelModules = [ "amdgpu.runpm=0" ];

  # MJP 2024-10-18 supposedly, pkgs.rocmPackages doesn't exist.  I can clearly see
  # that it does, and yet, it claims it does not :-(
  systemd.tmpfiles.rules = [
#    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  hardware.opengl = {
    # extraPackages   = with pkgs; [ amdvlk rocmPackages.clr.icd ];
    extraPackages   = with pkgs; [ amdvlk ];
    # For 32 bit applications
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];

    driSupport      = true; # This is already enabled by default
    driSupport32Bit = true; # For 32 bit applications
  };
}
