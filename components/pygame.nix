{ pkgs, ... }:

{
  environment.systemPackages =
#    with pkgs;
    let
      pygame2     = ps: ps.callPackage ../pkgs/pygame      {};
      pygame-zero = ps: ps.callPackage ../pkgs/pygame-zero { pygame = pygame2 ps; };
    in
      [
        (pkgs.python.withPackages(pyPkgs: with pyPkgs; [ pygame numpy
                                                         (pygame-zero pyPkgs)
                                                       ]))
      ];
}
