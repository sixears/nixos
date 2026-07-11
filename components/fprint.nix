{ config, ...}:

{
  services.fprintd.enable = true;

  security.pam.services = {
    # ? console login to be fingerprint-authenticatable
    login.fprintAuth = false;
    # ? sudo commands to be fingerprint-authenticatable
    sudo.fprintAuth = true;
    swaylock.fprintAuth = true;
    # https://discourse.nixos.org/t/swaylock-u2f-how-to-get-working-fallback/45352
    # needed to allow *both* fingerprint & password to swaylock
    swaylock.rules.auth.unix.order =
      config.security.pam.services.swaylock.rules.auth.fprintd.order - 10;
  };
}
