{ config, pkgs, ... }:

{
  users.groups.fletch.gid = 1005;

  users.users.fletch = {
    isNormalUser = true;
    name        = "fletch";
    group       = "fletch";
    extraGroups = [
      "wheel" "disk" "users"
    ];
    createHome  = true;
    uid         = 1005;
    home        = "/home/fletch";
    shell       = "/run/current-system/sw/bin/bash";
    openssh.authorizedKeys.keyFiles = [
      ./authorized_keys.fletch
    ];
  };

#  environment.etc.fletch-authkey = {
#    source = ./authorized_keys.fletch;
#    target = "ssh/authorized_keys.fletch";
#  };
}
