{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive4"    = { label = "b-archive4"; fsType = "xfs"; };

    "/backup/a2"          = { device  = "/backup/archive4/a2"          ;
                              options = [ "bind" ]; };
    "/backup/a4"          = { device  = "/backup/archive4/a4" ;
                              options = [ "bind" ]; };
    "/backup/ftp"         = { device  = "/backup/archive4/ftp"         ;
                              options = [ "bind" ]; };
    "/backup/MP3-Archive" = { device  = "/backup/archive4/MP3-Archive" ;
                              options = [ "bind" ]; };
    "/backup/EBooks"      = { device  = "/backup/archive4/EBooks"      ;
                              options = [ "bind" ]; };
    "/backup/resource"    = { device  = "/backup/archive4/resource"    ;
                              options = [ "bind" ]; };
    "/backup/Audiobooks"  = { device  = "/backup/archive4/Audiobooks";
                              options = [ "bind" ]; };
    "/backup/Audiobooks-Childrens" =
                           { device  = "/backup/archive4/Audiobooks-Childrens";
                             options = [ "bind" ]; };
  };
}
