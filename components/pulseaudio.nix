{ pkgs, ... }:

{
  # https://nixos.wiki/wiki/PulseAudio
  hardware.pulseaudio =
    {
      enable = true;
      # https://bbs.archlinux.org/viewtopic.php?id=185736
      daemon.config =
        { default-fragments = "5"; default-fragment-size-msec = "2"; };
    };
  nixpkgs.config.pulseaudio  = true;

  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
