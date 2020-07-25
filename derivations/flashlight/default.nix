{ stdenv
, fetchFromGitHub
, arrayfire
, cereal
, cmake
, gloo
, mkl-dnn
, mpich
, blas
}:

stdenv.mkDerivation {
  name = "flashlight";

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "flashlight";
    rev = "716d1b0913be1c26e446ed37450a5081c371a749";
    sha256 = "1lglk1j4bk0i1ax4nhvaddf9724739im9wcab0rlymc3nyj7k003";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ arrayfire blas gloo mpich cereal ];

  NIX_CFLAGS_COMPILE = [ "-I${cereal}/include/cereal" ];

  cmakeFlags = [
    "-DMKLDNN_ROOT=${mkl-dnn}"

    "-DFLASHLIGHT_BACKEND=CPU"
    "-DFL_BUILD_TESTS=OFF"
    "-DFL_BUILD_EXAMPLES=OFF"
  ];

  meta = with stdenv.lib; {
    description = "A fast, flexible machine learning library written entirely in C++";
    license = licenses.bsd3;
    homepage = "https://github.com/facebookresearch/flashlight";
  };
}
