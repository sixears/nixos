{ idle-suspend-time ? "30m", ... }:

{
  # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "suspend";
    extraConfig = ''
      HandlePowerKey=hibernate
      IdleAction=hibernate
      IdleActionSec=${idle-suspend-time}
    '';
  };
}
