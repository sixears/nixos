{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/backup/archive4"    = { label = "b-archive4"; fsType = "xfs"; };

    "/backup/a2"          = { device  = "/backup/archive4/a2"          ;
                              options = [ "bind" ]; fsType = "none"; };
    "/backup/a4"          = { device  = "/backup/archive4/a4"          ;
                              options = [ "bind" ]; fsType = "none"; };
    "/backup/ftp"         = { device  = "/backup/archive4/ftp"         ;
                              options = [ "bind" ]; fsType = "none"; };
    "/backup/MP3-Archive" = { device  = "/backup/archive4/MP3-Archive" ;
                              options = [ "bind" ]; fsType = "none"; };
    "/backup/EBooks"      = { device  = "/backup/archive4/EBooks"      ;
                              options = [ "bind" ]; fsType = "none"; };
    "/backup/resource"    = { device  = "/backup/archive4/resource"    ;
                              options = [ "bind" ]; fsType = "none"; };
    "/backup/Audiobooks"  = { device  = "/backup/archive4/Audiobooks"  ;
                              options = [ "bind" ]; fsType = "none"; };
    "/backup/Audiobooks-Childrens" =
                            { device  = "/backup/archive4/Audiobooks-Childrens";
                              options = [ "bind" ]; fsType = "none"; };
    "/backup/nsa2"        = { device  = "/backup/archive4/nsa2"        ;
                              options = [ "bind" ]; fsType = "none"; };

  };
}
