{ pkgs }:
let
  Log-Dispatch-FileRotate = import ../Log-Dispatch-FileRotate { inherit pkgs; };
in
  pkgs.perlPackages.buildPerlModule rec {
    pname   = "Log-Info";
    version = "2.00";

    src = pkgs.fetchurl {
      url = "mirror://cpan/authors/id/F/FL/FLUFFY/${pname}-${version}.tar.gz";
      sha256 = "03vsjh91rb9p4rcd6yq77nvdjal99kih7aml17g4ya495p6dgcbp";
    };

    patches = [ ./test-pm-tempdir.patch ./def-trans-t-tempdir.patch
                ./defaults-t-tempdir.patch
                ./Log-Info-pm-no-warnings-experimental.patch
              ];
    buildInputs = with pkgs.perlPackages; [ ];
    propagatedBuildInputs = with pkgs.perlPackages; [ ClassMethodMaker IOAll
                                                      IPCRun Log4Perl
                                                      LogDispatch
                                                      Log-Dispatch-FileRotate
                                                      TermProgressBar
                                                    ];

    doCheck = false;
  }
