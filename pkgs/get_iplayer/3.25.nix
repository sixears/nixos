# {stdenv, fetchFromGitHub, atomicparsley, flvstreamer, ffmpeg, makeWrapper, perl, buildPerlPackage, perlPackages, rtmpdump}:
{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
with nixpkgs.stdenv.lib;

buildPerlPackage rec {
  name = "get_iplayer-${version}";
  version = "3.25";
  
  src = fetchFromGitHub {
    owner = "get-iplayer";
    repo = "get_iplayer";
    rev = "v${version}";
    # nix-prefetch-github --rev v3.24 get-iplayer get_iplayer | jq -r .sha256
    sha256 = "1qjcxdpjr7ad82fvv17885ylw6as25dm0ghz7937g287h8y3qwr1";
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
