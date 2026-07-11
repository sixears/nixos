{ pkgs, system }:

let
  # Run a command (with given env; in the nix sense of env), read its output
  # to populate a variable.
  # see pkgs/build-support/trivial-builders.nix for runCommand defn.
  readCommand = name: env: command:
    pkgs.lib.strings.fileContents (pkgs.runCommand name env command);

  src         = ./src;

  bash        = pkgs.bash;
  coreutils   = pkgs.coreutils;

  confs       = derivation {
                  name      = "openvpn";
                  builder   = "${bash}/bin/bash";
                  bash      = bash;
                  src       = src;
                  args      = [ ./builder.sh ];

                  inherit coreutils;
                  inherit system;
                };
in
  confs
