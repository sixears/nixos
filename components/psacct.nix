{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.acct ];

  systemd.services.accton = {
    description = "turn on process accounting";
    after = [ "network.target" ];
    serviceConfig  =  {
      Type            = "oneshot";
      ExecStart       = "${pkgs.accton}/sbin/accton /var/log/account/pacct";
      RemainAfterExit = "yes";
      ExecStop        = "${pkgs.accton}/sbin/accton off";
      StandardOutput  = "journal";
      StandardError   = "journal";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
