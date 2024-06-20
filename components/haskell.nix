{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    stylish-haskell
    (ghc.withHoogle (haskellPackages:
              (with haskellPackages;
                     [
                       aeson ansi-wl-pprint base-unicode-symbols classy-prelude
                       hgettext HTTP neat-interpolation safe-exceptions
                       sqlite-simple uniplate word-wrap xmonad-contrib

                       reactive-banana

                       # required for nsa/stories/ws.com/parser.hs
                       tagsoup
                     ]
              )))
  ];
}
