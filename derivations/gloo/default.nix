{ stdenv
, fetchgit
, cmake
, mpich
}:

let
  revision = "4e65f7d769b5958a63947ace45962d214471c027";
in

stdenv.mkDerivation {
  name = "gloo";

  src = fetchgit {
    url = "https://github.com/facebookincubator/gloo.git";
    rev = revision;
    sha256 = "1w7589npzxba9p6a3wbwg6ajdndpjh0b5q3bg0wq48i4xcny39dr";
  };

  buildInputs =
    [ cmake
      mpich
    ];

  cmakeFlags =
    [ "-DBUILD_SHARED_LIBS=ON"
      "-DUSE_MPI=ON"
    ];

  meta = with stdenv.lib; {
    description = "Collective Communications library from Facebook";
    license = licenses.bsd3;
    homepage = "https://github.com/facebookincubator/gloo";
  };
}
