nixos-rebuild --target-host red --flake ~+/#red --verbose  build --option substituters 'https://cache.nixos.org'
nixos-rebuild --target-host red --flake ~+/#red --verbose  build --option substituters https://cache.nixos.org # --offline
nixos-rebuild --target-host red --flake ~+/#red --verbose  build --option substituters https://cache.nixos.org # --offline
