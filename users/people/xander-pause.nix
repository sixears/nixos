{ pkgs, ... }:


{
#      &timezone(Europe/London) * 0-6,9-15,22-23 * * 1-5 if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -STOP -U xander,steam; fi
# Nothing before 7AM any day
#      &timezone(Europe/London) * 0-7      * * * if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -STOP -U xander,steam; fi

## # Stop at 915PM Sun-Thurs
##       &timezone(Europe/London) 15-59 21      * * 0-4 if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -STOP -U xander,steam; fi
##       &timezone(Europe/London) * 22-23      * * 0-4 if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -STOP -U xander,steam; fi
##
## # Stop at 1115PM Fri-Sat
##       &timezone(Europe/London) 15-59 23      * * 5-6 if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -STOP -U xander,steam; fi
##
##
## #      &timezone(Europe/London) * 7-8,16-19      * * * if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -CONT -U xander,steam; fi
## # Run 7AM-915PM Sun-Thurs
##       &timezone(Europe/London) * 7-20           * * 0-4 if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -CONT -U xander,steam; fi
##       &timezone(Europe/London) 0-14 21           * * 0-4 if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -CONT -U xander,steam; fi
## # Run 7AM-1115PM Fri-Sat
##       &timezone(Europe/London) * 7-22           * * 5-6 if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -CONT -U xander,steam; fi
##       &timezone(Europe/London) 0-14 23           * * 5-6 if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -CONT -U xander,steam; fi

# Stop at 1115PM Fri-Sat
###      &timezone(Europe/London) 15-59 23      * * * if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -STOP -U xander,steam; fi


#      &timezone(Europe/London) * 7-8,16-19      * * * if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -CONT -U xander,steam; fi
# Run 7AM-1115PM
###      &timezone(Europe/London) * 7-22           * * * if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -CONT -U xander,steam; fi
###      &timezone(Europe/London) 0-14 23           * * * if ${pkgs.procps}/bin/pgrep -U xander,steam > /dev/null; then ${pkgs.procps}/bin/pkill -CONT -U xander,steam; fi

  services.fcron.systab =
    ''
    '';
}
