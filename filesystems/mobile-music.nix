{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/Music" = { label = "mobile-music";  options = [ "user" "noauto" "exec" ]; };
  };
}
