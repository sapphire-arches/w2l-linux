{ stdenv
, fetchFromGitHub
, cmake
, pkgconfig
, arrayfire
, blas
, bzip2
, flac
, flashlight
, glog
, google-gflags
, kenlm
, libogg
, libsndfile
, libvorbis
, lzma
, mkl, mkl-dnn
, zlib
, fftw
}:

stdenv.mkDerivation rec {
  name = "wav2letter";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "wav2letter";
    rev = "1db2513841e9d7727aeddb6863b22f4c230eb9f1";
    sha256 = "0vq9jcdnqjaxhjr63xsdff82xn8f7wb402g1zzkfxg622zj5gq13";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
  ];

  buildInputs = [
    lzma

    fftw
    arrayfire
    blas
    bzip2
    flac
    flashlight
    glog
    google-gflags
    kenlm
    libogg
    libsndfile
    libvorbis
    mkl
    mkl-dnn
    zlib
  ];

  NIX_CFLAGS_COMPILE = [ "-I${mkl}/include/fftw" ];

  cmakeFlags = [
    "-DDW2L_BUILD_LIBRARIES_ONLY=on"
    "-DW2L_BUILD_TESTS=NO"
    "-DW2L_LIBRARIES_USE_CUDA=OFF"
    "-DW2L_CRITERION_BACKEND=CPU"
    "-DKENLM_MODEL_HEADER=${kenlm}/include/lm/model.hh"
    "-DFFTW_LIB=${mkl}/lib/libmkl_intel_lp64.so"
    "-DFFTWF_LIB=${mkl}/lib/libmkl_intel_lp64.so"
    "-DFFTWL_LIB=${mkl}/lib/libmkl_intel_lp64.so"
  ];

  buildFlags = [ "w2l" "libwav2letter++.a" ];

  installPhase = ''
    install -D --target $out/lib libwav2letter++.a libw2l.so
    ln -s $out/lib/libw2l.so{,.1}
    install -D --target $out/include ../w2l.h
  '';

  meta = with stdenv.lib; {
    description = "A fast open source speech processing toolkit from the Speech Team at Facebook AI Research";
    license = licenses.bsd3;
    homepage = "https://github.com/facebookresearch/wav2letter";
  };
}

