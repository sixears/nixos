{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive0"          = { label  = "a-archive0"                  ; fsType = "xfs";       };
    "/cargo"             = { device = "/archive0/cargo"             ; options = [ "bind" ]; };
    "/get-iplayer"       = { device = "/archive0/get-iplayer"       ; options = [ "bind" ]; };
    "/home-backup"       = { device = "/archive0/home-backup"       ; options = [ "bind" ]; };
    "/BLU-RAY"           = { device = "/archive0/BLU-RAY"           ; options = [ "bind" ]; };
    "/Children's Movies" = { device = "/archive0/Children's Movies" ; options = [ "bind" ]; };
    "/MUSIC-DVD"         = { device = "/archive0/MUSIC-DVD"         ; options = [ "bind" ]; };
    "/MUSIC-FILMS"       = { device = "/archive0/MUSIC-FILMS"       ; options = [ "bind" ]; };
    "/MUSIC-VIDEO"       = { device = "/archive0/MUSIC-VIDEO"       ; options = [ "bind" ]; };
  };
}
