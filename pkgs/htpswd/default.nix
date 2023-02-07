{ pkgs, system }:

# reference to apache's htpasswd, because thttpd's uses
# /proc/sys/crypto/fips_enabled which doesn't exist, and causes a segv.
# lighttpd doesn't provide an htpasswd.

let
  src = "${pkgs.apacheHttpd}/bin/htpasswd";
in
  with pkgs;

derivation {
  name      = "htpswd";
  builder   = "${bash}/bin/bash";
  src       =  src;
  args      =  [ ./builder.sh ];

  inherit coreutils apacheHttpd;

  inherit system;
}
