# {stdenv, fetchFromGitHub, atomicparsley, flvstreamer, ffmpeg, makeWrapper, perl, buildPerlPackage, perlPackages, rtmpdump}:
{ nixpkgs }:

with nixpkgs;
with nixpkgs.stdenv.lib;

buildPerlPackage rec {
  name = "get_iplayer-${version}";
  version = "3.17";
  
  src = fetchFromGitHub {
    owner = "get-iplayer";
    repo = "get_iplayer";
    rev = "v${version}";
    sha256 = "0mqa9sp2lrrb612hmghkqwh2jhm5vcsvy7w9ap7sc2ckx45i8wyw";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ];
  propagatedBuildInputs = with perlPackages; [HTMLParser HTTPCookies LWP LWPProtocolHttps Mojolicious XMLLibXML XMLSimple];

  preConfigure = "touch Makefile.PL";
  doCheck = false;
  outputs = [ "out" "man" ];

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1
    cp get_iplayer $out/bin
    wrapProgram $out/bin/get_iplayer --suffix PATH : ${makeBinPath [ atomicparsley ffmpeg flvstreamer rtmpdump ]} --prefix PERL5LIB : $PERL5LIB
    cp get_iplayer.1 $out/share/man/man1
  '';

  meta = {
    description = "Downloads TV and radio from BBC iPlayer";
    license = licenses.gpl3Plus;
    homepage = https://squarepenguin.co.uk/;
    platforms = platforms.all;
  };
  
}
