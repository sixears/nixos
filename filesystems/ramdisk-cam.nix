{ ... }:

{
  fileSystems = {
    "/cam"   = { options=["size=2G"]; fsType = "tmpfs"; };
  };
}
