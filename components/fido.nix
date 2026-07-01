{...}:

{
  hardware.u2f.enable = true;

  security.pam.u2f = {
    enable = true;
    control = "sufficient";
  };

  security.pam.services = {
    swaylock.u2fAuth = true;
  }
}
