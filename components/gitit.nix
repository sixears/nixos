{ config, lib, pkgs, ... }:

let
  # r2020_09_25=import /nix/var/nixpkgs/master.2020-09-25.52075a/default.nix {};
  # gitit = r2020_09_25.haskellPackages.gitit;
  gitit       = pkgs.haskellPackages.gitit;
  gitit_bin   = "${gitit}/bin/gitit";
  gitit_cfg   = import ../pkgs/gitit.cfg.nix { inherit pkgs; };
  canon_url   = "gitit.sixears.co.uk";
  https_port  = 5002;
  acme-cert   = import ../pkgs/acme-cert.nix   { inherit pkgs; };
  cert-expiry = import ../pkgs/cert-expiry.nix { inherit pkgs; };
in
  {
    imports = [ ../users/system/gitit.nix ./nginx.nix ./fcron.nix ];

    # pseudo-random start times to spread the load
    # https://go-acme.github.io/lego/usage/cli/renew-a-certificate/
    services.fcron.systab = ''
      44 2 * * * ${acme-cert}/bin/acme-cert ${canon_url}
      54 2 * * * ${cert-expiry}/bin/cert-expiry ${canon_url}:${toString https_port}
    '';

    environment.systemPackages = with pkgs; [ gitit ];
    networking.firewall.allowedTCPPorts = [ https_port ];

    containers.gitit =
      {
        config = { config, ...}:
        {
            imports = [ ../users/system/gitit.nix ];
            system.stateVersion = "22.05";

            systemd.services.gitit =
              {
                wantedBy = [ "multi-user.target" ];
                # after = [ "network.target" ];
                description = "start the gitit markdown/git/haskell wiki";
                environment =
                  {
                    SSH_AUTH_SOCK = "${pkgs.openssh}/bin/ssh-agent";
                  };
                serviceConfig =
                  {
                    Type = "simple";
                    User = "gitit";
                    ExecStart = "${gitit_bin} -f ${gitit_cfg}";
                    WorkingDirectory = "/home/gitit";
                  };
                # this path is *additive*
                # texlive for pdflatex (see gitit-cfg)
                path = [ pkgs.git pkgs.texlive.combined.scheme-basic ];
              };
        };
      };

    containers.gitit =
      {
        autoStart = true;
        bindMounts =
          {
            "/home/gitit" = { hostPath = "/home/gitit"; isReadOnly = false; };
          };
      };

    services.nginx =
      let
        cert_dir = "/var/lib/acme/certificates";
      in
        {
          virtualHosts."${canon_url}" = {
            listen = [ { ssl = true; addr = "0.0.0.0"; port = https_port; } ];
            sslCertificate    = "${cert_dir}/${canon_url}.crt";
            sslCertificateKey = "${cert_dir}/${canon_url}.key";
            forceSSL   = true;
            root       = "/dev/null";
            # use htpswd (-c) to write (create) the auth file
            basicAuthFile = "/var/cred/gitit.cred";
            # 5001 is configured in gitit-cfg
            locations  = { "/" = { proxyPass = "http://localhost:5001/"; }; };
          };
        };
  }
