{ config, ... }:

{
  mkUserSyncthing = user: {
    "syncthing-${user}" = {
      description = "Syncthing service for user ${user}";
      after = [ "network.target" ];
      environment = { STNOUPGRADE = "yes"; };
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "on-failure";
        SuccessExitStatus = "2 3 4";
        RestartForceExitStatus="3 4";
        User = user;
        Group = "users";
        PermissionsStartOnly = true;
        ExecStart = "${config.services.syncthing.package}/bin/syncthing -no-restart -no-browser -logflags=0";
      };
    };
  };
}
