{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable     = true;
    forwardX11 = true;
    hostKeys   = [ { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; } ];
    passwordAuthentication = false;
    permitRootLogin = "no";
    extraConfig = ''
                    AllowAgentForwarding yes
                  '';
  };
}
