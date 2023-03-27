{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 9997 ];

  environment.systemPackages = with pkgs; [ thttpd ];

  systemd.services.camthttpd = {
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.thttpd}/bin/thttpd -D -p 9997 -r -d /cam -l /cam/camthttpd.log -i /cam/camthttpd.pid";
    };
  };
}
