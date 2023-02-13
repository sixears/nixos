#!/run/current-system/sw/bin/bash

set -eu -o pipefail
nixos-rebuild --target-host red --flake ~+/#red --verbose  build --option substituters https://cache.nixos.org # --offline
