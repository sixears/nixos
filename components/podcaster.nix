{ config, lib, pkgs, system, ... }:

let
  http_port   = 8080;
  https_port  = 60880;
  acme-cert   = import ../pkgs/acme-cert.nix   { inherit pkgs; };
  cert-expiry = import ../pkgs/cert-expiry.nix { inherit pkgs; };
  podcaster   = import ../pkgs/podcaster       { inherit pkgs system; };
in
  {
    networking.firewall.allowedTCPPorts = [ http_port https_port ];

    imports = [ ./nginx.nix ./fcron.nix ];

    # pseudo-random start times to spread the load
    # https://go-acme.github.io/lego/usage/cli/renew-a-certificate/
    services.fcron.systab = ''
      17 1 * * * ${acme-cert}/bin/acme-cert podcasts.sixears.co.uk
      27 1 * * * ${cert-expiry}/bin/cert-expiry podcasts.sixears.co.uk:${toString https_port}
    '';

    systemd.services.podcaster = {
      description = "Podcast server";
      after = [ "network.target" "syslog.service" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ${pkgs.rsync}/bin/rsync -avPL --delete ${podcaster}/ /run/podcaster/
        ${pkgs.coreutils}/bin/ln -sfn /bin/podcast /run/podcaster/htdocs/
      '';
      serviceConfig = {
        TimeoutStartSec = 0;
        ExecStart = ''
          ${pkgs.systemd}/bin/systemd-nspawn -D /run/podcaster/ -E TERM=vt102 -E PATH=/bin \
          '--bind-ro=/get-iplayer/radio/Im Sorry I Havent A Clue/':/htdocs/podcasts/sorry  \
          '--bind-ro=/get-iplayer/radio/News Quiz Extra:/htdocs/podcasts/news_quiz_extra'  \
          '--bind-ro=/get-iplayer/radio/News Quiz:/htdocs/podcasts/news_quiz'              \
          '--bind-ro=/get-iplayer/radio/Just a Minute:/htdocs/podcasts/just_a_minute'      \
          '--bind-ro=/get-iplayer/radio/The Unbelievable Truth/:/htdocs/podcasts/unbelievable_truth' \
           /bin/thttpd -p ${toString http_port} -d /htdocs -c podcast -l /thttpd.log -i /thttpd.pid -D -nos
        '';
        Restart = "on-failure";
      };
    };

    services.nginx = {
      virtualHosts."podcasts.sixears.co.uk" = {
        listen = [ { ssl = true; addr = "0.0.0.0"; port = https_port; } ];
        forceSSL   = true;
        sslCertificate    = "/var/lib/acme/certificates/podcasts.sixears.co.uk.crt";
        sslCertificateKey = "/var/lib/acme/certificates/podcasts.sixears.co.uk.key";
        root       = "/dev/null";
        # use htpswd (-c) to write (create) the auth file
        basicAuthFile = "/var/cred/podcasts.cred";
        locations  = {
        "/" = {
          proxyPass = "http://localhost:${toString http_port}/";
          extraConfig = ''
                          sub_filter 'http://192.168.0.24:${toString http_port}/podcasts/' 'https://podcasts.sixears.co.uk:${toString https_port}/podcasts/';
                          sub_filter_once off;
                          sub_filter_types application/rss+xml;
                          # prevent compression, as compression allegedly borks sub_filter
                          # https://stackoverflow.com/questions/31893211/http-sub-module-sub-filter-of-nginx-and-reverse-proxy-not-working
                          proxy_set_header Accept-Encoding "";
                        '';
         };
        };
      };
    };
  }
