{ stdenv
, fetchgit
, cmake
, pkgconfig
, arrayfire
, flac
, flashlight
, glog
, google-gflags
, kenlm
, libogg
, libsndfile
, libvorbis
, lzma
, mkl
, mkl-dnn
, blas
}:

let
  revision = "5b1ea6900adcee739350acfe77011bda0a5e04f6";
in

stdenv.mkDerivation {
  name = "wav2letter";
  src = fetchgit {
    url = "https://github.com/bobtwinkles/wav2letter.git";
    rev = revision;
    sha256 = "1w4k6c1yqxvg2b26khgj9j5y2dnysik9ys8hkgn7y92irga9fxdx";
  };

  nativeBuildInputs = [ kenlm.src lzma.dev ];

  buildInputs =
    [ cmake
      pkgconfig

      arrayfire
      blas
      flac
      flashlight
      glog
      google-gflags
      kenlm
      libsndfile
      libogg
      libvorbis
      mkl
      mkl-dnn
    ];

  cmakeFlags =
    [ "-DW2L_BUILD_TESTS=NO"
      "-DW2L_LIBRARIES_USE_CUDA=OFF"
      "-DW2L_CRITERION_BACKEND=CPU"
      "-DKENLM_MODEL_HEADER=${kenlm.src}/lm/model.hh"
      "-DFFTW_INCLUDES=${mkl}/include/fftw"
      "-DFFTW_LIBRARIES=${mkl}/lib/libmkl_intel_lp64.so"
      "-DFFTWF_LIB=${mkl}/lib/libmkl_intel_lp64.so"
      "-DFFTWL_LIB=${mkl}/lib/libmkl_intel_lp64.so"
    ];

  buildPhase = '' make w2l libwav2letter++.a '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    install libwav2letter++.a $out/lib
    install libw2l.a $out/lib
  '';

  meta = with stdenv.lib; {
    description = "A fast open source speech processing toolkit from the Speech Team at Facebook AI Research";
    license = license.bsd3;
    homepage = "https://github.com/facebookresearch/wav2letter";
  };
}

