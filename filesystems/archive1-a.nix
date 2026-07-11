{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive1" = { label = "a-archive1"; fsType = "xfs"; };

    "/HOME"              = { device = "/archive1/HOME"              ; options = [ "bind" ]; };
    "/Children's TV"     = { device = "/archive1/Children's TV"     ; options = [ "bind" ]; };
    "/Movies"            = { device = "/archive1/Movies"            ; options = [ "bind" ]; };
    "/NEW"               = { device = "/archive1/NEW"               ; options = [ "bind" ]; };
    "/Fifteen"           = { device = "/archive1/Fifteen"           ; options = [ "bind" ]; };
    "/MUSIC-FILMS"       = { device = "/archive1/MUSIC-FILMS"       ; options = [ "bind" ]; };
    "/MUSIC-VIDEO"       = { device = "/archive1/MUSIC-VIDEO"       ; options = [ "bind" ]; };

    "/archive"           = { device = "/archive1/archive"           ; options = [ "bind" ]; };
  };
}
