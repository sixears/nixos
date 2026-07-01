final: prev: {
  linux-firmware = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs.git";
    rev = "846475fd";
  }) { config = {}; };
}
