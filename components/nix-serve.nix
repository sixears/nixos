{ pkgs, system, config, ... }:

# https://nixos.wiki/wiki/Binary_Cache
# pre-create the creds with ~/bin/nixos-bincache-cred
{
  imports = [ ../users/system/nix-serve.nix
              (import ./nginx.nix { inherit pkgs system; }) ];

  networking.firewall = {
    allowedTCPPorts = [ config.services.nix-serve.port ];
  };
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cred/nixos-bincache/cache-priv-key.pem";
  };

  services.nginx.virtualHosts."nixos-bincache.sixears.co.uk" = {
    serverAliases = [ "binarycache" ];
    locations."/" =
      {
      proxyPass =
        "http://localhost:${toString config.services.nix-serve.port}";
      extraConfig = ''
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    '';
    };
  };
}
