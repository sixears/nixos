{ pkgs, system
# , mp3-info ? import ../MP3Info { inherit pkgs system; }
, mp3-info ? pkgs.perlPackages.MP3Info
}:

let
  # Run a command (with given env; in the nix sense of env), read its output
  # to populate a variable.
  # see pkgs/build-support/trivial-builders.nix for runCommand defn.
  readCommand = name: env: command:
    pkgs.lib.strings.fileContents (pkgs.runCommand name env command);

  src     = ./src;

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
              name      = "podcast";
              builder   = "${bash}/bin/bash";
              bash      = bash;
              src       = src;
              args      = [ ./builder.sh ];

              mp3-info    = mp3-info;

              perllibs = ''${mp3-info}/lib/perl5/site_perl/

                           ${perls.ClassInspector}/lib/perl5/site_perl/
                           ${perls.FileShareDir}/lib/perl5/site_perl/
                           ${perls.BHooksEndOfScope}/lib/perl5/site_perl/
                           ${perls.ClassDataInheritable}/lib/perl5/site_perl/
                           ${perls.ClassSingleton}/lib/perl5/site_perl/
                           ${perls.DateTime}/lib/perl5/site_perl/
                           ${perls.DateTimeFormatMail}/lib/perl5/site_perl/
                           ${perls.DateTimeFormatW3CDTF}/lib/perl5/site_perl/
                           ${perls.DateTimeLocale}/lib/perl5/site_perl/
                           ${perls.DateTimeTimeZone}/lib/perl5/site_perl/
                           ${perls.DevelStackTrace}/lib/perl5/site_perl/
                           ${perls.ExceptionClass}/lib/perl5/site_perl/
                           ${perls.EvalClosure}/lib/perl5/site_perl/
                           ${perls.FileShareDir}/lib/perl5/site_perl/
                           ${perls.HTMLParser}/lib/perl5/site_perl/
                           ${perls.IOAll}/lib/perl5/site_perl/
                           ${perls.ModuleImplementation}/lib/perl5/site_perl/
                           ${perls.ModuleRuntime}/lib/perl5/site_perl/
                           ${perls.MROCompat}/lib/perl5/site_perl/
                           ${perls.namespaceautoclean}/lib/perl5/site_perl/
                           ${perls.namespaceclean}/lib/perl5/site_perl/
                           ${perls.PackageStash}/lib/perl5/site_perl/
                           ${perls.ParamsValidate}/lib/perl5/site_perl/
                           ${perls.ParamsValidationCompiler}/lib/perl5/site_perl/
                           ${perls.RoleTiny}/lib/perl5/site_perl/
                           ${perls.Specio}/lib/perl5/site_perl/
                           ${perls.SubIdentify}/lib/perl5/site_perl/
                           ${perls.SubExporterProgressive}/lib/perl5/site_perl/
                           ${perls.TryTiny}/lib/perl5/site_perl/
                           ${perls.XMLParser}/lib/perl5/site_perl/
                           ${perls.XMLRSS}/lib/perl5/site_perl/
                           ${perls.XMLWriter}/lib/perl5/site_perl/
                           ${perls.YAML}/lib/perl5/site_perl/
                         '';

                inherit coreutils perl;
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
#  podcast
#  image
  layer-dir
