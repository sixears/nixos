{ pkgs, ... }:


let
  user = "jj";
  steam-signal-dir =
    pkgs.writers.writeBashBin
      "steam-signal"
      ''
        if ${pkgs.procps}/bin/pgrep -U ${user} > /dev/null; then
          ${pkgs.procps}/bin/pkill -"$1" -U ${user}
        fi
      '';
  steam-signal = "${steam-signal-dir}/bin/steam-signal";
in {
  services.fcron.systab =
    ''
      # Nothing before 7AM any day
      &timezone(Europe/London) *     0-7   * * *   ${steam-signal} STOP

      # Run 7AM-915PM Sun-Thurs
      &timezone(Europe/London) *     7-20  * * 0-4 ${steam-signal} CONT
      &timezone(Europe/London) 0-14  21    * * 0-4 ${steam-signal} CONT
      # Stop at 915PM Sun-Thurs
      &timezone(Europe/London) 15-59 21    * * 0-4 ${steam-signal} STOP
      &timezone(Europe/London) *     22-23 * * 0-4 ${steam-signal} STOP

      # Run 7AM-1115PM Fri-Sat
      &timezone(Europe/London) *     7-22  * * 5-6 ${steam-signal} CONT
      &timezone(Europe/London) 0-14  23    * * 5-6 ${steam-signal} CONT

      # Stop at 1115PM Fri-Sat
      &timezone(Europe/London) 15-59 23    * * 5-6 ${steam-signal} STOP
    '';
}
