{ ... }: {
  services.sabnzbd = {
    enable = true;
    configFile = "/Deluge/sabnzbd/sabnzbd.ini";
  };
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
