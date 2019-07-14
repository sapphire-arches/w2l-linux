self: super:

{
  libfvad = super.callPackage ./libfvad { };
  mkl-dnn = super.callPackage ./mkl-dnn/default.nix { blas = super.mkl; } ;
  arrayfire = super.callPackage ./arrayfire/default.nix { blas = super.mkl; } ;
  cereal-develop = super.callPackage ./cereal/default.nix {} ;
  flashlight = super.callPackage ./flashlight/default.nix
    { arrayfire = arrayfire;
      cereal-develop = cereal-develop;
      blas = super.mkl;
      mkl-dnn = mkl-dnn;
    } ;
  kenlm = super.callPackage ./kenlm/default.nix {} ;
}
