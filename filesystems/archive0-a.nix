{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive0"          = { label  = "a-archive0"                  ; fsType = "xfs";       };
    "/cargo"             = { device = "/archive0/cargo"             ; options = [ "bind" ]; fsType = "none"; };
    "/get-iplayer"       = { device = "/archive0/get-iplayer"       ; options = [ "bind" ]; fsType = "none"; };
    "/home-backup"       = { device = "/archive0/home-backup"       ; options = [ "bind" ]; fsType = "none"; };
    "/BLU-RAY"           = { device = "/archive0/BLU-RAY"           ; options = [ "bind" ]; fsType = "none"; };
    "/Children's Movies" = { device = "/archive0/Children's Movies" ; options = [ "bind" ]; fsType = "none"; };
    "/MUSIC-DVD"         = { device = "/archive0/MUSIC-DVD"         ; options = [ "bind" ]; fsType = "none"; };
  };
}
