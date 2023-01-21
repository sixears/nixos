{ lib, ... }:

let
  domain         = "sixears.co.uk";
  cache-port     = 5000;
  cache-port-str = toString cache-port;
in
  {
    nix.settings = {
      substituters = [
        "https://cache.iog.io" # See ref (01)
      ] ++ (map (x: "http://" + x + "." + domain + ":" + cache-port-str + "/") [
        "nixos-bincache"
        "night"
      ]);

      trusted-public-keys = lib.mapAttrsToList (x: y: x + ":" + y) ({
        # See ref (01)
        "hydra.iohk.io" = "f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=";
      } // (with lib.attrsets;
            mapAttrs' (k: v: nameValuePair (k + "." + domain) v) {
        "nixos-bincache" = "qdbId5CKN01tH6SWL0YUsIG5fUmdZKRgYQ8Hh2C3STg=";
        "trance"         = "M2ebZ15Yk6V9Pi81MldTgNY7KdLukDj2rhzLibwq0t0=";
        "night"          = "uPZcQccenrbEivJ3vEHZtoybCQYxOQOJqQg4H6aQJm8=";
      }));
    };
  }

# References
# (01) https://input-output-hk.github.io/haskell.nix/tutorials/getting-started-flakes.html

