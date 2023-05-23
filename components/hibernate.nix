{ idle-suspend-time ? "30m", ... }:

{
  # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "hibernate";
    extraConfig = ''
      HandlePowerKey=hibernate
      IdleAction=hibernate
      IdleActionSec=${idle-suspend-time}
    '';
  };
}
