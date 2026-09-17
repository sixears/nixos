{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive1" = { label = "a-archive1"; fsType = "xfs"; };

    "/HOME"              = { device = "/archive1/HOME"              ; options = [ "bind" ]; fsType = "none"; };
    "/Children's TV"     = { device = "/archive1/Children's TV"     ; options = [ "bind" ]; fsType = "none"; };
    "/Movies"            = { device = "/archive1/Movies"            ; options = [ "bind" ]; fsType = "none"; };
    "/NEW"               = { device = "/archive1/NEW"               ; options = [ "bind" ]; fsType = "none"; };
    "/Fifteen"           = { device = "/archive1/Fifteen"           ; options = [ "bind" ]; fsType = "none"; };
    "/MUSIC-FILMS"       = { device = "/archive1/MUSIC-FILMS"       ; options = [ "bind" ]; fsType = "none"; };
    "/MUSIC-VIDEO"       = { device = "/archive1/MUSIC-VIDEO"       ; options = [ "bind" ]; fsType = "none"; };

    "/archive"           = { device = "/archive1/archive"           ; options = [ "bind" ]; fsType = "none"; };
  };
}
