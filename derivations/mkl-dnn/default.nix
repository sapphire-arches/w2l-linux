{ stdenv
, fetchgit
, autoreconfHook
, cmake
, curl
, pkgconfig
, blas
}:

stdenv.mkDerivation {
  name = "mkl-dnn";
  src = fetchgit {
    url = "https://github.com/intel/mkl-dnn.git";
    rev = "7de7e5d02bf687f971e7668963649728356e0c20";
    sha256 = "0j4za82k88s2k8wyh6aradh5i7196fj0xkcn8yagym5nbvdpd50c";
  };
  enableParallelBuilding = true;

  buildInputs = [ cmake blas ];

  cmakeFlags =
    [ "-DWITH_TEST=OFF"
      "-WITH_EXAMPLE=OFF"
    ];

  patches = [ ./patch.patch ];

  meta = with stdenv.lib; {
    description = "An open-source performance library for deep-learning applications";
    license = licenses.asl20;
    homepage = "https://github.com/intel/mkl-dnn";
  };
}
