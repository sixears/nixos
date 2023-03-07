{ config, lib, pkgs, ... }:

{
  boot =
    {
      kernelParams = [ "nvidia-drm.modeset=1" ];
    };

  nixpkgs.config.allowUnfree = true;

  # https://www.mythtv.org/wiki/User_Manual:JudderFree
  # https://discourse.nixos.org/t/getting-nvidia-to-work-avoiding-screen-tearing/10422/16
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    config = ''
    Section "Device"
      Identifier "nvidia"
      Driver "nvidia"
      Option "FlatPanelProperties" "Scaling = Native"
    EndSection
  '';
    screenSection = ''
#      Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';
  };

  # see also https://nixos.wiki/wiki/Nvidia
  #
  # > Fix screen tearing
  #
  # > You may often incounter screen tearing or artifacts when using proprietary
  # > Nvidia drivers. You can fix that by forcing full composition pipeline.
  # > Note: This has been reported to reduce the performance of some OpenGL
  # > applications and may produce issues in WebGL. It also drastically
  # > increases the time the driver needs to clock down after load.
# this fails to recognize the second screen on dog
##  services.xserver.screenSection = ''
##    Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
##    Option         "AllowIndirectGLXProtocol" "off"
##    Option         "TripleBuffer" "on"
##  '';
  services.xserver.exportConfiguration = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs;
      [ libvdpau-va-gl ];
    extraPackages32 = with pkgs.pkgsi686Linux;
      [ libva ];
  };
}
