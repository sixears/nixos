{ ... }:
{
  # Enable acpilight.  This will allow brightness control via xbacklight
  # from users in the video group.
  hardware.acpilight.enable = true;

  # create a symlink to /etc/X11/xorg.conf for visibility
  services.xserver.exportConfiguration = true;
}
