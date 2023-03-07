{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ thttpd ];
  networking.firewall.allowedTCPPorts = [ 808 ];

  systemd.services.thttpd = {
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.thttpd}/bin/thttpd -D -p 808 -r -d /ftp";
    };
  };
}
