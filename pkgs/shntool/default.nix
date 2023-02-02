# { lib, stdenv, fetchurl, flac }:
{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;

stdenv.mkDerivation {
  version = "3.0.10";
  pname = "shntool";

  src = fetchurl {
    url = "http://www.etree.org/shnutils/shntool/dist/src/shntool-3.0.10.tar.gz";
    sha256 = "00i1rbjaaws3drkhiczaign3lnbhr161b7rbnjr8z83w8yn2wc3l";
  };

  buildInputs = [ flac ];

  patches = [
    # support 24-bit WAVs & FLACs
    ./24bit.patch
  ];

  meta = {
    description = "Multi-purpose WAVE data processing and reporting utility";
    homepage = "http://www.etree.org/shnutils/shntool/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ jcumming ];
  };
}
