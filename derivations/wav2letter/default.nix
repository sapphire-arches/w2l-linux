{ stdenv
, fetchgit
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
, mkl
, mkl-dnn
, zlib
}:

let
  revision = "0f64f52975500b1c81dfb4147670d9e466e42759";
in

stdenv.mkDerivation rec {
  name = "wav2letter";
  src = fetchgit {
    url = "https://github.com/bobtwinkles/wav2letter.git";
    rev = revision;
    sha256 = "1ccdrw3dga86amm2m25nj10dla95vv6smfgf4jvwfx06jl04d1h2";
  };

  nativeBuildInputs = [ kenlm.src lzma.dev ];

  buildInputs =
    [ cmake
      pkgconfig

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

  cmakeFlags =
    [ "-DW2L_BUILD_TESTS=NO"
      "-DW2L_LIBRARIES_USE_CUDA=OFF"
      "-DW2L_CRITERION_BACKEND=CPU"
      "-DKENLM_MODEL_HEADER=${kenlm.src}/lm/model.hh"
      "-DFFTW_INCLUDES=${mkl}/include/fftw"
      "-DFFTW_LIB=${mkl}/lib/libmkl_intel_lp64.so"
      "-DFFTWF_LIB=${mkl}/lib/libmkl_intel_lp64.so"
      "-DFFTWL_LIB=${mkl}/lib/libmkl_intel_lp64.so"
    ];

  buildPhase = '' make w2l libwav2letter++.a '';

  # installPhase = ''
  #   mkdir -p $out/bin
  #   mkdir -p $out/lib
  #   mkdir -p $out/include
  #   install libwav2letter++.a $out/lib
  #   install libw2l.a $out/lib
  #   install ${src}/w2l.h $out/include
  # '';

  meta = with stdenv.lib; {
    description = "A fast open source speech processing toolkit from the Speech Team at Facebook AI Research";
    license = license.bsd3;
    homepage = "https://github.com/facebookresearch/wav2letter";
  };
}

