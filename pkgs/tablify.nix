{ pkgs, hlib }:

(hlib.mkHBin "tablify" ./tablify.hs {
  libs = p:
    (with hlib.hpkgs; [ ]) ++ (with p; [
      fpath-1-3
##      base1-0-0 log-plus-0-0 mockio-log-0-1 mockio-plus-0-3 optparse-plus-1-3
      stdmain-1-6
    ]);
}).pkg
