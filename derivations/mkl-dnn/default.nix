{ stdenv
, fetchFromGitHub
, autoreconfHook
, cmake
, curl
, pkgconfig
, blas
}:

stdenv.mkDerivation {
  name = "mkl-dnn";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "mkl-dnn";
    rev = "4bdffc2cb1c3d47df9604d35d2c7e5e47a13f1a6";
    sha256 = "03dycq2x4ihfsps4flw570hdhmkr9p49s9rzsdzwhz0l6d6qvcrw";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake blas ];

  NIX_CFLAGS_COMPILE = [ "-Wno-error=stringop-truncation" ];

  cmakeFlags = [
    "-DWITH_TEST=OFF"
    "-WITH_EXAMPLE=OFF"
  ];

  meta = with stdenv.lib; {
    description = "An open-source performance library for deep-learning applications";
    license = licenses.asl20;
    homepage = "https://github.com/intel/mkl-dnn";
  };
}
