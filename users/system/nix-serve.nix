{ ... }:

{
  imports = [ ./system.group.nix ];

  users.users.nix-serve = {
    name         = "nix-serve";
    isSystemUser = true;
    group        = "system";
    createHome   = false;
    uid          = 2006;
    home         = "/var/empty";
    shell        = "/run/current-system/sw/bin/nologin";
  };
}
