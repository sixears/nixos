{ pkgs, ... }:

{
  environment.systemPackages =
#    with pkgs;
    let
      pygame2     = ps: ps.callPackage ../pkgs/pygame      {};
      pygame-zero = ps: ps.callPackage ../pkgs/pygame-zero { pygame = pygame2 ps; };
    in
      [
        # 2021-03-20 python39.pygame wouldn't compile with 2020-09-25
        # pygame-zero needs a pygame >= 2; not currently available with
        # 2020-09-25
        (pkgs.python38.withPackages(pyPkgs: with pyPkgs; [ pygame numpy
                                                           (pygame-zero pyPkgs)
                                                         ]))
      ];
}
