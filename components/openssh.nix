{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable        = true;
    settings.X11Forwarding = true;
    hostKeys   = [ { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; } ];
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
    extraConfig = ''
                    AllowAgentForwarding yes
                  '';
  };
}
