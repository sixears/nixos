{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive4"    = { label = "a-archive4"; fsType = "xfs"; };

    "/a2"          = { device = "/archive4/a2"          ; options = [ "bind" ]; };
    "/a4"          = { device = "/archive4/a4"          ; options = [ "bind" ]; };
    "/ftp"         = { device = "/archive4/ftp"         ; options = [ "bind" ]; };
    "/MP3-Archive" = { device = "/archive4/MP3-Archive" ; options = [ "bind" ]; };
    "/EBooks"      = { device = "/archive4/EBooks"      ; options = [ "bind" ]; };
    "/resource"    = { device = "/archive4/resource"    ; options = [ "bind" ]; };
    "/Audiobooks"  = { device  = "/archive4/Audiobooks";
                       options = [ "bind" ]; };
    "/nsa2"        = { device = "/archive4/nsa2"        ; options = [ "bind" ]; };

    "/Audiobooks-Childrens" = { device  = "/archive4/Audiobooks-Childrens";
                                options = [ "bind" ]; };
  };
}
