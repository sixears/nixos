{ config, lib, pkgs, ... }:

{
  imports = [ ./nginx.nix ];

  services.nginx = {
    virtualHosts."www.sixears.co.uk" = {
      root = "/tmp/www";
      extraConfig = "autoindex on;";
    };
  };
}
