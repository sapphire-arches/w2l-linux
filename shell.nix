{ pkgs ? import <nixpkgs> {} }:

let
  libfvad = pkgs.callPackage ./derivations/libfvad/default.nix {} ;
  mkl-dnn = pkgs.callPackage ./derivations/mkl-dnn/default.nix { blas = pkgs.mkl; } ;
  arrayfire = pkgs.callPackage ./derivations/arrayfire/default.nix { blas = pkgs.mkl; } ;
  gloo = pkgs.callPackage ./derivations/gloo/default.nix {} ;
  flashlight = pkgs.callPackage ./derivations/flashlight/default.nix {
    inherit arrayfire mkl-dnn gloo;
    blas = pkgs.mkl;
  };
  kenlm = pkgs.callPackage ./derivations/kenlm/default.nix {} ;
  wav2letter = pkgs.callPackage ./derivations/wav2letter/default.nix {
    inherit arrayfire flashlight mkl-dnn kenlm;
    blas = pkgs.mkl;
  };
in
with pkgs; mkShell
  { buildInputs = [
        cmake
        pkgconfig
        clang
        binutils

        libfvad
        pulseaudio

        arrayfire
        mkl
        flac
        flashlight
        glog
        google-gflags
        kenlm
        lzma
        libsndfile
        libogg
        libvorbis
        mkl
        mkl-dnn
        wav2letter
        zlib
        bzip2
    ];
  }

