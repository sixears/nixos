{ pkgs, system }:

let
  # Run a command (with given env; in the nix sense of env), read its output
  # to populate a variable.
  # see pkgs/build-support/trivial-builders.nix for runCommand defn.
  readCommand = name: env: command:
    pkgs.lib.strings.fileContents (pkgs.runCommand name env command);

  src     = ./openvpn-no-autostart;

  bash         = pkgs.bash;
  coreutils    = pkgs.coreutils;
  env-replace  = pkgs.env-replace;
  gnugrep      = pkgs.gnugrep;
  gnutar       = pkgs.gnutar;
  gzip         = pkgs.gzip;
  perl         = pkgs.perl;
  perls        = pkgs.perlPackages;
  thttpd       = pkgs.thttpd;

  podcast = derivation {
              name      = "openvpn-no-autostart";
              builder   = "${bash}/bin/bash";
              bash      = bash;
              src       = src;
              args      = [ ./builder.sh ];

              inherit coreutils;
              inherit (pkgs) stdenv;
              inherit system;
            };

  image = pkgs.dockerTools.buildImage {
            name = "podcast-container";
            copyToRoot = [ podcast thttpd
                           pkgs.bashInteractive coreutils

                         ];
            config = {
              WorkingDir = "/";
            };
          };

  # find the name of the layer in the image, write it to eclayer in the store
  mkimage = "${pkgs.gzip}/bin/gzip --decompress --stdout $image"
            + " | ${pkgs.gnutar}/bin/tar tf -"
            + " | ${pkgs.gnugrep}/bin/grep layer.tar > $out";
  layer = readCommand "podcaster-layer" { inherit image;} mkimage;

  layer-dir = derivation {
                name      = "podcaster";

                inherit coreutils gnugrep gnutar gzip layer image;
                builder   = "${bash}/bin/bash";
                args      = [ ./extract.sh ];

                inherit system;
              };


in
  podcast
#  image
#  layer-dir
