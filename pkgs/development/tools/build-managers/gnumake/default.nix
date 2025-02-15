{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  guileSupport ? false,
  guile,
  # avoid guile depend on bootstrap to prevent dependency cycles
  inBootstrap ? false,
  pkg-config,
  gnumake,
}:

let
  guileEnabled = guileSupport && !inBootstrap;
in

stdenv.mkDerivation rec {
  pname = "gnumake";
  version = "4.4.1";

  src = fetchurl {
    url = "mirror://gnu/make/make-${version}.tar.gz";
    sha256 = "sha256-3Rb7HWe/q3mnL16DkHNcSePo5wtJRaFasfgd23hlj7M=";
  };

  # To update patches:
  #  $ version=4.4.1
  #  $ git clone https://git.savannah.gnu.org/git/make.git
  #  $ cd make && git checkout -b nixpkgs $version
  #  $ git am --directory=../patches
  #  $ # make changes, resolve conflicts, etc.
  #  $ git format-patch --output-directory ../patches --diff-algorithm=histogram $version
  #
  # TODO: stdenv’s setup.sh should be aware of patch directories. It’s very
  # convenient to keep them in a separate directory but we can defer listing the
  # directory until derivation realization to avoid unnecessary Nix evaluations.
  patches = lib.filesystem.listFilesRecursive ./patches;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = lib.optionals guileEnabled [ guile ];

  configureFlags = lib.optional guileEnabled "--with-guile";

  outputs = [
    "out"
    "man"
    "info"
  ];
  separateDebugInfo = true;

  passthru.tests = {
    # make sure that the override doesn't break bootstrapping
    gnumakeWithGuile = gnumake.override { guileSupport = true; };
  };

  meta = with lib; {
    description = "Tool to control the generation of non-source files from sources";
    longDescription = ''
      Make is a tool which controls the generation of executables and
      other non-source files of a program from the program's source files.

      Make gets its knowledge of how to build your program from a file
      called the makefile, which lists each of the non-source files and
      how to compute it from other files. When you write a program, you
      should write a makefile for it, so that it is possible to use Make
      to build and install the program.
    '';
    homepage = "https://www.gnu.org/software/make/";

    license = licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "make";
    platforms = platforms.all;
  };
}
