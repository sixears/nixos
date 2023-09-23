{ pkgs }: pkgs.writers.writeBashBin "nix-install" ''
# install a nix package to our default profile
exec nix profile install $NIXPKGS#"$1" "''${@:2}"
''

# Local Variables:
# mode: sh
# End:
