{ config, lib, pkgs, ... }:

let
  mirrorfs = import ../pkgs/mirrorfs.nix { inherit pkgs; };
in
  {

    imports = [ ./fcron.nix ];

    # run at one minute past midnight
    services.fcron.systab =
      ''
        # one minute past midnight
        &runas(root) 1 0 * * * ${mirrorfs}
      '';
  }
