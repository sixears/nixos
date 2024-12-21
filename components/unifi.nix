{ pkgs, ... }:

{
  services.unifi = {
    # Note that the previous default MongoDB version was 5.0 and MongoDB only
    # supports migrating one major version at a time; therefore, you may wish to
    # set `services.unifi.mongodbPackage = pkgs.mongodb-6_0;` and activate your
    # configuration before upgrading again to the default `mongodb-7_0`
    # supported by `unifi8`.
    mongodbPackage = pkgs.mongodb-6_0;
    unifiPackage = pkgs.unifi8;
    openFirewall = true;
    enable = true;
  };
}
