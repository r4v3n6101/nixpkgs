{
  lib,
  fetchFromGitHub,
  stdenv,
  pkg-config,
  wafHook,

  python3,
  SDL2,
  freetype,
  fontconfig,
  libopus,
  libpng,
  libjpeg,
  libjpeg_turbo,
  curl,

  game-folder ? "hl2",
}:
stdenv.mkDerivation {
  pname = "source-engine";
  version = "0-unstable-2026-05-31";

  src = fetchFromGitHub {
    owner = "nillerusr";
    repo = "source-engine";
    rev = "ed8209cc35c61fbd8ddff8480962a01c981eef2f";
    hash = "sha256-tpuvpr5mTZJmZzBkqXU4bqbRA4x++nykbM4O9hlpW/E=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace datamodel/dmserializerkeyvalues2.cpp \
      --replace 'Warning( temp2 );' 'Warning( "%s", temp2 );'

    tmp=$(mktemp)
    {
      echo '#if defined(__APPLE__)'
      echo '#include <alloca.h>'
      echo '#endif'
      cat ivp/ivp_utility/ivu_types.hxx
    } > "$tmp"
    mv "$tmp" ivp/ivp_utility/ivu_types.hxx
  '';

  nativeBuildInputs = [
    python3
    pkg-config
    wafHook
  ];

  buildInputs = [
    SDL2
    freetype
    fontconfig
    libopus
    libpng
    libjpeg
    libjpeg_turbo
    curl
  ];

  dontAddPrefix = true;

  wafConfigureFlags = [
    "-T release"
    "--build-games=${game-folder}"
  ];

  wafInstallFlags = [ "--destdir=${placeholder "out"}" ];

  meta = {
    homepage = "https://github.com/nillerusr/source-engine";
    description = "Modified source engine (2017) developed by Valve, leaked in 2020";
    # TODO : Source SDK License
    # license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ r4v3n6101 ];
  };
}
