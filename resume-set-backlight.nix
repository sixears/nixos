{ pkgs, ... }:

let
  minlight = pkgs.writers.writeBash "minlight" ''
               xbacklight="${pkgs.acpilight}/bin/xbacklight"
               min=30
               [[ $min -gt $( $xbacklight -get ) ]] && $xbacklight -set $min
             '';
in
  {
    systemd.services.resume-set-backlight = {
      description        = "Set backlight to a minimum level on resume";
      wantedBy           = [ "post-resume.target" ];
      after              = [ "post-resume.target" ];
      script             = "${minlight}";
      serviceConfig.Type = "oneshot";
    };
  }
