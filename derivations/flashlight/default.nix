{ stdenv
, fetchgit
, arrayfire
, cereal-develop
, cmake
, gloo
, mkl-dnn
, mpich
, blas
}:

let
  revision = "6ec9dc7e9f57400801794b2e2f02317031883268";
in

stdenv.mkDerivation {
  name = "flashlight";

  src = fetchgit {
    url = "https://github.com/facebookresearch/flashlight.git";
    rev = revision;
    sha256 = "1afhyjfwf583j3q27arjmv4783hiqhjabqqjvni7clv1gccqc4m3";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ arrayfire ];
  buildInputs = [ cmake blas gloo mpich ];

  cmakeFlags =
    [ "-DCEREAL_INCLUDE_DIR=${cereal-develop}/include"
      "-DMKLDNN_ROOT=${mkl-dnn}"

      "-DFLASHLIGHT_BACKEND=CPU"
      "-DFL_BUILD_TESTS=OFF"
      "-DFL_BUILD_EXAMPLES=OFF"
    ];

  patches = [ ./remove-cereal-external.patch ];

  meta = with stdenv.lib; {
    description = "A fast, flexible machine learning library written entirely in C++";
    license = licenses.bsd3;
    homepage = "https://github.com/facebookresearch/flashlight";
  };
}
