# svn checkout https://svn.sixears.co.uk:8248/svn/test1/

{ pkgs, ... }:

let
  user    = "wwwrun";
  group   = "nginx";
  svnroot = "/var/lib/svnroot";
  test1   = "${svnroot}/test1";
  acme-cert = import ../pkgs/acme-cert.nix { inherit pkgs; };
  docroot = pkgs.writeTextFile
    {
      name        = "svn-httpd-docroot";
      destination = "/docroot/index.html";
      text        =
        ''
          <html>
            <body>
            This is SVN Serve
            </body>
          </html>
        '';
    };
  htpasswd = pkgs.writeText "svn.htpasswd"
    # user martyn, password martyn
    # originally created with htpasswd -c <file> martyn
    ''
      martyn:$apr1$B0Evo5Cd$eF4rxa9Hlh4tf6ZBbq72a.
    '';
  authz = pkgs.writeText "svn.authz"
    ''
      [/]
      * = rw
    '';

  # the actual dir create is done by systemd.tmpfiles, since only root can make the dir
  svn-prep-dir = pkgs.writers.writeBash "svn-mk-dir"
    ''
      [[ -e ${test1} ]] || ${pkgs.subversion}/bin/svnadmin create ${test1}
    '';
in
  {
    imports = [ ./fcron.nix ];

    services.fcron.systab =
      ''
        @daily ${acme-cert}/bin/acme-cert svn.sixears.co.uk
      '';

    services.httpd.group  = group; # to access acme ssl certs
    services.httpd.enable = true;
    services.httpd.adminAddr = "email@addr.org";
    services.httpd.extraModules = [
      # note that order is *super* important here
      { name = "dav_svn";
        path = "${pkgs.apacheHttpdPackages.subversion}/modules/mod_dav_svn.so"; }
      { name = "authz_svn";
        path = "${pkgs.apacheHttpdPackages.subversion}/modules/mod_authz_svn.so"; }
    ];
    systemd.services.httpd.preStart = "${svn-prep-dir}";
    systemd.tmpfiles.rules =
      # Type Path Mode User Group CleanupAge Argument
      [ "d ${svnroot} 0750 ${user} ${group} - -" ];
    services.httpd.virtualHosts =
      {
        svn =
          {
            hostName = "svn.sixears.co.uk";
            documentRoot = "${docroot}/docroot";
            listen = [{ ip="*"; port = 8248; ssl=true; }];
            sslServerCert="/var/lib/acme/certificates/svn.sixears.co.uk.crt";
            sslServerKey="/var/lib/acme/certificates/svn.sixears.co.uk.key";
            locations."/svn".extraConfig =
              ''
                DAV                svn
                SVNParentPath      ${svnroot}
                AuthzSVNAccessFile ${authz}
                AuthName           "SVN Repositories"
                AuthType           Basic
                AuthUserFile       ${htpasswd}
                Require            valid-user
              '';
          };
      };
  }
