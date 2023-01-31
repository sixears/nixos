{ pkgs, Log-Info }:

with pkgs;
pkgs.perlPackages.buildPerlModule rec {
  version = "0.99";
  pname = "Getopt-Plus";

  src = pkgs.fetchurl {
    url = "mirror://cpan/authors/id/F/FL/FLUFFY/${pname}-${version}.tar.gz";
    sha256 = "0vsr4d0myv98aqbs7rc5rvqdpfz1vg1w7b5wyn4i6lmycp1wxxqk";
  };

  patches = [ ./test-pm-tempdir.patch ];
  buildInputs = [ ];
  propagatedBuildInputs = with pkgs.perlPackages; [ ClassMethodMaker IOAll
                                                    IPCRun Log-Info TestDeep
                                                    TestDifferences
                                                    TestException TestMost
                                                  ];

  doCheck = false;
}
