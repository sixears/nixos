{ logicalCores }:
{ lib, ... }:
{
  # This option defines the maximum number of jobs that Nix will try to build in
  # parallel. The default is auto, which means it will use all available logical
  # cores. It is recommend to set it to the total number of logical cores in
  # your system (e.g., 16 for two CPUs with 4 cores each and hyper-threading).
  nix.settings.max-jobs = lib.mkDefault logicalCores;

  systemd.services.nix-daemon.environment.TMPDIR = "/local/tmp/nix-daemon";
}
