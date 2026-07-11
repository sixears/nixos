final: prev: {
#  hardware.firmware = import (builtins.fetchGit {
#    url = "https://github.com/NixOS/nixpkgs.git";
#    rev = "846475fdddf617ba9b5ae256bd2e8608d0b42a91";
#  }) { system = "x86_64-linux"; };
}
