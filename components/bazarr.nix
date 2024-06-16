{ ... }: {
  services.bazarr = {
    enable  = true;
    group   = "media";
  };
  networking.firewall.allowedTCPPorts = [ 6767 ];
}
