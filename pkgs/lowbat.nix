{ pkgs }: pkgs.writers.writeBashBin "lowbat" ''

${pkgs.acpi}/bin/acpi -b | \
  ${pkgs.perl}/bin/perl -nE '/(Not|Dis)? ?(charging|Full|Unknown), (\d+)%/i and say "$1$2 $3"' | \
    {
      read -r status capacity

      if [ "$status" = Discharging -a "$capacity" -lt 5 ]; then
        ${pkgs.inetutils}/bin/logger "Critical battery threshold"
        # hibernate has a habit of crashing...
        ${pkgs.systemd}/bin/systemctl suspend # hibernate
      fi
    }
''

# Local Variables:
# mode: sh
# End:
