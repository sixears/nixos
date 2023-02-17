{ config, lib, pkgs, ... }:

let defaults = # -a : Equivalent to turning on all of the following Directives:
               # '-H' to check the SMART health status, '-f' to report failures
               # of Usage (rather than Prefail) Attributes, '-t' to track
               # changes in both Prefailure and Usage Attributes, '-l error' to
               # report increases in the number of ATA errors, '-l selftest' to
               # report increases in the number of Self-Test Log errors, '-l
               # selfteststs' to report changes of Self-Test execution status,
               # '-C 197' to report nonzero values of the current pending sector
               # count, and '-U 198' to report nonzero values of the offline
               # pending sector count.

               # -n standby,24 : don't spin up disks that are in sleep/standby;
               #                 up to 24 times in succession (after that, the
               #                 drives are spun up anyway)

               # -o on : Enables SMART Automatic Offline Testing when smartd
               #         starts up and has no further effect.

               # -S on : Enables or SMART autosave of device vendor-specific
               #         attributes.

               # -l xerror : Report if the number of ATA errors reported in the
               #             Extended Comprehensive SMART error log has
               #             increased since the last check.

               # -s S/../.././01 - run a Short Self-Test at 1AM every day
               #                   (around mirrorfs time)
               # -s L/../../6/01 - run a Long Self-Test at 1AM every Saturday
               #                   morning.
               
               # -W 0,40,48 : log if a drive exceeds 40C, issue a CRIT and email
               #              if exceeds 48C

               "-a -o on -n standby,24 -S on -s (S/../.././01|L/../../6/01) -l xerror -W 0,40,48";
 in {
  services.smartd = {
    enable       = true;
    autodetect   = true;
    extraOptions = [ "--interval=3600" ];

    defaults = {
      autodetected = defaults;
      monitored    = defaults;
    };

    notifications.mail = {
      enable = true;
      recipient = "root@sixears.co.uk";
    };

    notifications.test = true;
  };
}
