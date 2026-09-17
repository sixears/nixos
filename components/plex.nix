{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 32400 ];

  imports = [ ./unfree.nix ../users/system/plex.nix ];

  services.plex = {
    enable       = true;
    openFirewall = true;
    extraPlugins = [  (builtins.path {
    name = "Audnexus.bundle";
    path = pkgs.fetchFromGitHub {
      owner = "djdembeck";
      repo = "Audnexus.bundle";
      rev = "v0.2.8";
      sha256 = "sha256-IWOSz3vYL7zhdHan468xNc6C/eQ2C2BukQlaJNLXh7E=";
    };
  })
];

    extraScanners = [  (pkgs.fetchFromGitHub {
    owner = "ZeroQI";
    repo = "Absolute-Series-Scanner";
    rev = "773a39f502a1204b0b0255903cee4ed02c46fde0";
    sha256 = "4l+vpiDdC8L/EeJowUgYyB3JPNTZ1sauN8liFAcK+PY=";
  })
];
  };

  services.fcron.systab =
    ''
      30 22 * * sun-thu ${pkgs.procps}/bin/pkill -STOP -f plex
      59 23 * * fri-sat ${pkgs.procps}/bin/pkill -STOP -f plex
      0   7 * * *       ${pkgs.procps}/bin/pkill -CONT -f plex
    '';
}
