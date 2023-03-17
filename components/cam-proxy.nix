{ config, lib, pkgs, ... }:

let
  https_port  = 61791;
  https_port_x = 61792;
  acme-cert   = import ../pkgs/acme-cert.nix   { inherit pkgs; };
  cert-expiry = import ../pkgs/cert-expiry.nix { inherit pkgs; };
in
  {
    imports = [ ./nginx.nix ./fcron.nix ];

    networking.firewall.allowedTCPPorts = [ https_port https_port_x ];

    # pseudo-random start times to spread the load
    # https://go-acme.github.io/lego/usage/cli/renew-a-certificate/
    services.fcron.systab = ''
      23 4 * * * ${acme-cert}/bin/acme-cert cam.sixears.co.uk
      33 4 * * * ${cert-expiry}/bin/cert-expiry cam.sixears.co.uk:${toString https_port}
      43 4 * * * ${acme-cert}/bin/acme-cert cam-front-x.sixears.co.uk
      53 4 * * * ${cert-expiry}/bin/cert-expiry cam-front-x.sixears.co.uk:${toString https_port_x}
    '';

    services.nginx.virtualHosts."cam.sixears.co.uk" = {
      listen     = [{ ssl = true; addr = "0.0.0.0"; port = https_port; }];
      forceSSL   = true;
      sslCertificate    = "/var/lib/acme/certificates/cam.sixears.co.uk.crt";
      sslCertificateKey = "/var/lib/acme/certificates/cam.sixears.co.uk.key";

      root       = "/dev/null";
      # use htpswd (-c) to write (create) the auth file
      basicAuthFile = "/var/cred/cam.cred";
      locations  = {
        "/hall-upper/" = {
          proxyPass = "http://192.168.0.76:7777/";
        };
        "/hall-lower/" = {
          proxyPass = "http://192.168.0.78:7777/";
        };
        "/lounge/" = {
          proxyPass = "http://192.168.0.80:7777/";
        };
        "/study/" = {
          proxyPass = "http://192.168.0.82:7777/";
        };
        "/kitchen/" = {
          proxyPass = "http://192.168.0.83:7777/";
        };
        "/front" = {
          proxyPass = "http://192.168.0.75:7777/";
          extraConfig = ''
            sub_filter 'http://cam.sixears.co.uk/' 'https://cam.sixears.co.uk:${toString https_port}/front/';
          '';
        };
      };
    };

    services.nginx.virtualHosts."cam-front-x.sixears.co.uk" = {
    listen     = [{ ssl = true; addr = "0.0.0.0"; port = https_port_x; }];
      forceSSL   = true;
      sslCertificate    = "/var/lib/acme/certificates/cam-front-x.sixears.co.uk.crt";
      sslCertificateKey = "/var/lib/acme/certificates/cam-front-x.sixears.co.uk.key";
      root       = "/dev/null";
      # use htpswd (-c) to write (create) the auth file
      basicAuthFile = "/var/cred/cam.cred";
      locations  = {
        "/" = {
          proxyPass = "http://192.168.0.75:7777/";
        };
      };
    };
  }
