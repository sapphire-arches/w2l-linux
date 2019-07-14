{ stdenv
, fetchgit
, cmake
}:

stdenv.mkDerivation {
  name = "cereal-develop";

  src = fetchgit {
    url = "https://github.com/USCiLab/cereal.git";
    rev = "319ce5f5ee5b76cb80617156bf7c95474a2938b1";
    sha256 = "1r3bsl9jj6rdym46qmpcqzpgaw2fga5ccgqwlh9j1dbh98vmcgl5";
  };

  enableParallelBuilding = true;

  buildInputs = [ cmake ];

  cmakeFlags = [ "-DJUST_INSTALL_CEREAL=ON" ];

  meta = with stdenv.lib; {
    description = "cereal is a header-only C++11 serialization library";
    license = licenses.bsd3;
    homepage = "http://uscilab.github.io/cereal/";
  };
}
