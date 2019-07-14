{ fetchgit
, stdenv
, cmake
, boost162
, lzma
}:

let
  commit = "e47088ddfae810a5ee4c8a9923b5f8071bed1ae8";
in

stdenv.mkDerivation {
  name = "kenlm";
  src = fetchgit {
    url = "https://github.com/kpu/kenlm.git";
    rev = commit;
    sha256 = "0jzf58lpa5siha6jgbpgy0kfgdzwj5jxgz8fm2dp4szwfhmilhvr";
  };

  enableParallelBuilding = true;

  buildInputs = [ cmake boost162 lzma ];

  installPhase = ''
    make install
    mkdir $out/lib
    install lib/* $out/lib
  '';


  cmakeFlags = [ ];

  meta = with stdenv.lib; {
    description = "Language model inference code by Kenneth Heafield";
    license = license.lgpl;
    homepage = "https://github.com/kpu/kenlm";
  };
}
