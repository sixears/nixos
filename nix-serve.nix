{ pkgs, system, config, ... }@attrs:

# https://nixos.wiki/wiki/Binary_Cache
# sudo mkdir /var/cred/nixos-bincache --mode=0700
# sudo nix-store --generate-binary-cache-key $(hostname -f) \
#   /var/cred/nixos-bincache/cache-priv-key.pem             \
#   /var/cred/nixos-bincache/cache-pub-key.pem
# sudo chown -R nix-serve /var/cred/nixos-bincache
# # should be redundant...
# sudo chmod 0600 /var/cred/nixos-bincache/cache-priv-key.pem
# sudo chmod 0755 /var/cred/nixos-bincache
{
  networking.firewall = {
    allowedTCPPorts = [ config.services.nix-serve.port ];
  };
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cred/nixos-bincache/cache-priv-key.pem";
  };

  imports = [ (import ./nginx.nix { inherit pkgs system; }) ];
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
