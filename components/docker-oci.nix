{ ... }:

# https://wiki.nixos.org/wiki/Docker
# https://medium.com/@stylishavocado/managing-docker-containers-in-nixos-fbda0f666dd1.

{
  virtualisation.docker = {
    # Use the rootless mode - run Docker daemon as non-root user
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
  };
}
