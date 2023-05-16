{ suspend-hibernate-time ? "2h", idle-suspend-time ? "30m", ... }:

{
  # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=${idle-suspend-time}
    '';
  };
  systemd.sleep.extraConfig = "HibernateDelaySec=${suspend-hibernate-time}";
}
