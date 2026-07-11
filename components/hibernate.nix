{ idle-suspend-time ? "30m", ... }:

{
  # Suspend-then-hibernate everywhere
  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandlePowerKey  = "hibernate";
      IdleAction      = "hibernate";
      IdleActionSec   = "${idle-suspend-time}";
    };
  };
}
