{ ... }: {
  services.prowlarr.enable = true;
  networking.firewall.allowedTCPPorts = [ 9696 ];
}
