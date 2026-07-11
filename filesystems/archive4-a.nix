{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/archive4"    = { label = "a-archive4"; fsType = "xfs"; };

    "/a2"          = { device = "/archive4/a2"          ;
                       options = [ "bind" ]; fsType = "none"; };
    "/a4"          = { device = "/archive4/a4"          ;
                       options = [ "bind" ]; fsType = "none"; };
    "/ftp"         = { device = "/archive4/ftp"         ;
                       options = [ "bind" ]; fsType = "none"; };
    "/MP3-Archive" = { device = "/archive4/MP3-Archive" ;
                       options = [ "bind" ]; fsType = "none"; };
    "/EBooks"      = { device = "/archive4/EBooks"      ;
                       options = [ "bind" ]; fsType = "none"; };
    "/resource"    = { device = "/archive4/resource"    ;
                       options = [ "bind" ]; fsType = "none"; };
    "/Audiobooks"  = { device  = "/archive4/Audiobooks";
                       options = [ "bind" ]; fsType = "none"; };
    "/nsa2"        = { device = "/archive4/nsa2"        ;
                       options = [ "bind" ]; fsType = "none"; };

    "/Audiobooks-Childrens" = { device  = "/archive4/Audiobooks-Childrens";
                                options = [ "bind" ]; fsType = "none"; };
  };
}
