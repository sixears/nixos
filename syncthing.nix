{ config, ... }:

{
  config.services.syncthing =
    {
      enable        = true;
      systemService = false;
    };
}
