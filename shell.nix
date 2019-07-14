{ pkgs ? import <nixpkgs> {} }:

let
  libfvad = pkgs.callPackage ./derivations/libfvad/default.nix {} ;
  mkl-dnn = pkgs.callPackage ./derivations/mkl-dnn/default.nix { blas = pkgs.mkl; } ;
  arrayfire = pkgs.callPackage ./derivations/arrayfire/default.nix { blas = pkgs.mkl; } ;
  cereal-develop = pkgs.callPackage ./derivations/cereal/default.nix {} ;
  gloo = pkgs.callPackage ./derivations/gloo/default.nix {} ;
  flashlight = pkgs.callPackage ./derivations/flashlight/default.nix
    { arrayfire = arrayfire;
      cereal-develop = cereal-develop;
      mkl-dnn = mkl-dnn;
      gloo = gloo;
      blas = pkgs.mkl;
    } ;
  kenlm = pkgs.callPackage ./derivations/kenlm/default.nix {} ;
  wav2letter = pkgs.callPackage ./derivations/wav2letter/default.nix
    { arrayfire = arrayfire;
      flashlight = flashlight;
      kenlm = kenlm;
      mkl-dnn = mkl-dnn;
      blas = pkgs.mkl;
    } ;
in
with pkgs; mkShell
  { buildInputs = [
        cmake
        pkgconfig
        clang
        binutils

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
    ];
  }

