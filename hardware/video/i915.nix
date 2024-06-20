{ pkgs, ... }:

{
  # we need linux 5.19+ for sound support, but with 5.19.8 at least;
  # the i915 crashes the display
  ## no longer required since nixos-24.05
  ## boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
  # https://wiki.archlinux.org/title/Dell_XPS_13_(9310)#Random_Hangs_on_i915_with_kernel
  # Random Hangs on i915 with kernel
  #
  #   Occasionally the laptop hangs when running the i915 Linux
  #   driver.
  #   This results in an occasional visual delay to keyboard inputs
  #   and makes the system appear to be crashing.
  #
  # The bug report for this issue can be found here:
  # https://gitlab.freedesktop.org/drm/intel/-/issues/3496
  #
  # Set panel self refresh to off in the kernel parameters:
  # i915.enable_psr=0 i915.enable_fbc=1.
  boot.kernelParams = [ "i915.enable_psr=0" "i915.enable_fbc=1" ];
}
