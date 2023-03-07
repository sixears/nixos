{ lib, fetchPypi, buildPythonPackage
, pygame, numpy
#, python, pkg-config, libX11 , SDL, SDL_image, SDL_mixer, SDL_ttf, libpng, libjpeg, portmidi, freetype
}:

buildPythonPackage rec {
  pname = "pgzero";
  version = "1.2.1";
#  version = "1.2";

  src = fetchPypi {
    inherit pname version;
sha256 = "01k1iv1qdy9kyizr3iysxqfmy10w38qvjfxx1hzarjr8y0hc1bcc";
# 1.2    sha256 = "05whvgl2hl8lxxmpbcasicmfjac47kc0zslxf4j5l8y68pal3rli";
  };

  nativeBuildInputs = [
##    pkg-config SDL
  ];

  buildInputs = [
    pygame numpy
##    SDL SDL_image SDL_mixer SDL_ttf libpng libjpeg
##    portmidi libX11 freetype
  ];

  # Tests fail with ModuleNotFoundError: No module named 'test.test'
  doCheck = false;

##  preConfigure = ''
##    sed \
##      -e "s/origincdirs = .*/origincdirs = []/" \
##      -e "s/origlibdirs = .*/origlibdirs = []/" \
##      -e "/'\/lib\/i386-linux-gnu', '\/lib\/x86_64-linux-gnu']/d" \
##      -e "/\/include\/smpeg/d" \
##      -i buildconfig/config_unix.py
##    ${lib.concatMapStrings (dep: ''
##      sed \
##        -e "/origincdirs =/a\        origincdirs += ['${lib.getDev dep}/include']" \
##        -e "/origlibdirs =/a\        origlibdirs += ['${lib.getLib dep}/lib']" \
##        -i buildconfig/config_unix.py
##      '') buildInputs
##    }
##    LOCALBASE=/ ${python.interpreter} buildconfig/config.py
##  '';

  meta = with lib; {
    description = "A zero-boilerplate 2D games framework";
    homepage = "http://pypi.python.org/pypi/pgzero";
    license = licenses.lgpl3;
    platforms = platforms.linux;
  };
}
