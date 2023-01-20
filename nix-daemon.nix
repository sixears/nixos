{ ... }:
{
  systemd.services.nix-daemon.environment.TMPDIR = "/local/tmp/nix-daemon";
}
