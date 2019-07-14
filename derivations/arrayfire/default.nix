{ stdenv
, pkgs
, fetchurl
, symlinkJoin
, cmake
, boost162
, blas
, pkgconfig
}:

let
  version = "3.6.2";
  blasName = (builtins.parseDrvName blas.name).name;
in

stdenv.mkDerivation {
  name = "arrayfire";

  src = fetchurl {
    url = "http://arrayfire.com/arrayfire_source/arrayfire-full-${version}.tar.bz2";
    sha256 = "00p1d56s4qd3ll5f0980zwpw3hy8m6v0gd7v34rim4bkmslb8gvg";
  };

  nativeBuildInputs = stdenv.lib.optional (blasName != "mkl") pkgs.fftw.dev ;
  buildInputs =
    [ boost162
      pkgconfig
      cmake
      blas
    ] ++ stdenv.lib.optional (blasName != "mkl") pkgs.fftw;

  cmakeFlags =
    [ "-DCMAKE_BUILD_TYPE=Release"
      "-DAF_BUILD_CUDA=OFF"
      "-DAF_BUILD_OPENCL=OFF"
      "-DAF_BUILD_EXAMPLES=OFF"
      "-DAF_WITH_GRAPHICS=OFF"
      "-DAF_WITH_IMAGEIO=OFF"
      "-DAF_WITH_LOGGING=OFF"
      "-DBUILD_TESTING=OFF" ]
    ++
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
            "-DMKL_THREAD_LAYER=IntelOpenMP"

            "-DUSE_CPU_MKL=ON"
          ])
    ++
      stdenv.lib.optionals (blasName != "mkl")
        [ "-DFFTWF_LIBRARY=${pkgs.fftwFloat}/lib/libfftw3f.so"
        ];

  patches = [ ./patch-08a601f.patch ./rewrite_OMP_streq.patch ];

  meta = with stdenv.lib; {
    description = "A general-purpose computational tool that simplifies the process of developing software that targets parallel and massively-parallel architectures including CPUs, GPUs, and other hardware acceleration devices";
    license = licenses.bsd3;
    homepage = "https://arrayfire.com/";
  };
}
