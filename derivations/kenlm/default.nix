{ fetchFromGitHub
, stdenv
, cmake
, boost
, lzma
}:

stdenv.mkDerivation {
  name = "kenlm";

  src = fetchFromGitHub {
    owner = "kpu";
    repo = "kenlm";
    rev = "87e85e66c99ceff1fab2500a7c60c01da7315eec";
    sha256 = "1qh16zc5wljn9l662ci9n7z683rwrmzs032f9adss84q0b1ldf4j";
  };

  nativeBuildInputs = [ cmake boost ];

  buildInputs = [ lzma ];

  installPhase = ''
    make install
    mkdir -p $out/{lib,include}
    install lib/* $out/lib
    pushd ..
    find lm util -type f -iname '*.hh' -exec cp --parents '{}' $out/include/ \;
    popd
  '';

  meta = with stdenv.lib; {
    description = "Language model inference code by Kenneth Heafield";
    license = licenses.lgpl21;
    homepage = "https://github.com/kpu/kenlm";
  };
}
