{ pkgs, hlib }:

(hlib.mkHBin "queue" ./queue.hs {
  libs = p:
    (with hlib.hpkgs; [ timers ]) ++ (with p; [
      base1-0-0 log-plus-0-0 mockio-log-0-1 mockio-plus-0-3 optparse-plus-1-3
      stdmain-1-5
    ]);
}).pkg
