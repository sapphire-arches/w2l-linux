w2l-linux
----
*NOTE* This repository is mostly capturing work I hacked together over a weekend.
Use at your own risk etc. etc.

This is a small demo application that uses
[wav2letter](https://github.com/facebookresearch/wav2letter)
to convert speach to text.
You'll need an accoustic model, token list, language model, and lexicon to use it.
This is based heavily on work done by [lunixbochs](https://github.com/facebookresearch/wav2letter/issues/327).
Build instructions are captured by the included Nix derivations -
on any Nix system, all you should have to do is run `nix-shell`
at the root of this repository and
the system will build and install all the required libraries.
If you don't have nix,
you can either read the derivations (hopefully not that bad)
or file an issue and I'll add build instructions here.
