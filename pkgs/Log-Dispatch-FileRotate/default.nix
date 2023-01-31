{ pkgs }:

pkgs.perlPackages.buildPerlPackage rec {
  version = "1.36";
  pname = "Log-Dispatch-FileRotate";

  src = pkgs.fetchurl {
    url = "mirror://cpan/authors/id/M/MS/MSCHOUT/${pname}-${version}.tar.gz";
    sha256 = "0vlmi17p7fky3x58rs7r5mdxi6l5jla8zhlb55kvssxc1w5v2b27";
  };

  buildInputs = with pkgs.perlPackages; [ ];
  propagatedBuildInputs = with pkgs.perlPackages; [ DateManip LogDispatch
                                                    PathTiny TestWarn ];
}
