{ config, lib, pkgs, ... }:

let
  acme-cert   = import ../pkgs/acme-cert.nix   { inherit pkgs; };
  cert-expiry = import ../pkgs/cert-expiry.nix { inherit pkgs; };
in
  {
    services.minio = {
      enable  = true;
      browser = true;

      # format of credentials file:
      # ```
      # MINIO_ROOT_USER=Transpotting
      # MINIO_ROOT_PASSWORD=BetteDavisEyes
      # ```
      rootCredentialsFile = "/var/creds/minio.creds";

      dataDir = [ "/home/minio" ];
    };

    networking.firewall.allowedTCPPorts = [ 9000 9001 ];
    users.users.martyn.extraGroups = [ "minio" ];

    imports = [ ./fcron.nix ./nginx.nix ];

    services.fcron.systab = ''
      @daily ${acme-cert}/bin/acme-cert canine.sixears.co.uk
      @daily ${cert-expiry}/bin/cert-expiry canine.sixears.co.uk:9001
    '';

    services.nginx = {
      virtualHosts."canine.sixears.co.uk" = {
        listen = [ { ssl = true; addr = "0.0.0.0"; port = 9001; } ];
        sslCertificate    = "/var/lib/acme/certificates/canine.sixears.co.uk.crt";
        sslCertificateKey = "/var/lib/acme/certificates/canine.sixears.co.uk.key";
        # minio itself is running on :9000, hence that isn't ssl
        forceSSL   = true;
        root       = "/dev/null";
        # use htpswd (-c) to write (create) the auth file
  #     does not play well with minio: nginx wants basic auth, but minio does not
  #      basicAuthFile = "/var/cred/minio.cred";
        locations  = { "/" = { proxyPass = "http://localhost:9000/"; }; };
      };
    };
  }
