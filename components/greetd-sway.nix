{ pkgs, ... }:

let
  ways     = import ../pkgs/ways.nix { inherit pkgs; };
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
in
  {
    services.greetd = {
      enable = true;
      settings = {
       default_session.command = ''
         ${tuigreet}    \
           --time       \
           --asterisks  \
           --user-menu  \
           --cmd ${ways}
       '';
      };
    };

    environment.etc."greetd/environments".text = ''
      sway
    '';
  }
