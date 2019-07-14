{ fetchgit
, stdenv
, autoreconfHook
, pkgconfig }:

let
  commit = "ee69951e7ec6ed3a0caf547f35f103280b9831de";
in

stdenv.mkDerivation {
  name = "libfvad";
  src = fetchgit {
    url = "https://github.com/talonvoice/libfvad.git";
    rev = commit;
    sha256 = "0jzwjx0ca6m1c422q54k1gw4y5ik18zcf9rx9bsbnbkgbmgh1agp";
  };
  enableParallelBuilding = true;

  autoreconfPhase = ''
    autoreconf -i
  '';

  nativeBuildInputs = [ pkgconfig autoreconfHook ];

  configureFlags =
    [ "--disable-examples"
    ];

  meta = with stdenv.lib; {
    description = "A fork of the VAD engine that is part of the WebRTC Native Code package (https://webrtc.org/native-code/), for use as a standalone library independent from the rest of the WebRTC code.";
    homepage = "https://github.com/talonvoice/libfvad";
  };
}
