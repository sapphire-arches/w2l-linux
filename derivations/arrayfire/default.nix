{ stdenv
, fftw
, fftwFloat
, fetchFromGitHub
, symlinkJoin
, cmake
, boost17x
, blas
, pkg-config
}:

let
  blasName = (builtins.parseDrvName blas.name).name;
in stdenv.mkDerivation rec {
  pname = "arrayfire";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner= "arrayfire";
    repo= "arrayfire";
    rev = "v${version}";
    sha256 = "179mbh08z040kfy31lg5ay2jvsyal890jg98ki6cq2k9wxvr24v0";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config cmake ];
  buildInputs = [
    boost17x blas
  ] ++ stdenv.lib.optional (blasName != "mkl") fftw;

  cmakeFlags = [
    "-DAF_BUILD_CUDA=OFF"
    "-DAF_BUILD_OPENCL=OFF"
    "-DAF_BUILD_EXAMPLES=OFF"
    "-DAF_WITH_GRAPHICS=OFF"
    "-DAF_WITH_IMAGEIO=OFF"
    "-DAF_WITH_LOGGING=OFF"
    "-DBUILD_TESTING=OFF"
  ] ++
      stdenv.lib.optionals (blasName == "mkl") (
        let
          mkl_lp64 = "${blas}/lib/intel64/libmkl_intel_lp64.so";
        in
          [ "-DFFTW_LIBRARY=${mkl_lp64}"
            "-DFFTWF_LIBRARY=${mkl_lp64}"
            "-DFFTW_INCLUDE=${blas}/include/fftw"
            "-DCBLAS_LIBRARY=${mkl_lp64}"
            "-DLAPACKE_LIB=${mkl_lp64}"
            "-DLAPACK_LIB=${mkl_lp64}"
            "-DLAPACKE_INCLUDES=${blas}/include"
            "-DUSE_CPU_MKL=ON"
          ])
    ++
      stdenv.lib.optionals (blasName != "mkl")
        [ "-DFFTWF_LIBRARY=${fftwFloat}/lib/libfftw3f.so"
        ];

  preConfigure = ''
    cmakeFlagsArray+=("-DMKL_THREAD_LAYER=Intel OpenMP")
  '';

  meta = with stdenv.lib; {
    description = "A general-purpose computational tool that simplifies the process of developing software that targets parallel and massively-parallel architectures including CPUs, GPUs, and other hardware acceleration devices";
    license = licenses.bsd3;
    homepage = "https://arrayfire.com/";
  };
}
