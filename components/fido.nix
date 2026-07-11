{ config, ...}:

{
  # hardware.u2f.enable = true;

  security.pam.u2f = {
    enable = true;
    control = "sufficient";
    settings = {
      userVerification = "required";
    };
  };

  security.pam.services = {
    swaylock.u2fAuth = true;

    swaylock.rules.auth.unix.order =
      config.security.pam.services.swaylock.rules.auth.u2f.order - 10;
  };
}
