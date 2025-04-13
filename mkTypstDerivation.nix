{
  stdenvNoCC,
  typst,
  fetchFromGitHub,
  symlinkJoin,
}:
{
  name ? null,
  pname ? null,
  version ? null,
  src,
  unixTime ? 0,
  fontPaths ? [ ],
  typstPackages ? [ ],
  postPackagePhase ? "",
  stdenv ? stdenvNoCC,
  nativeBuildInputs ? [ ],
  buildInputs ? [ ],
  packagesHash ? "",
  typstPackagesRev ? "7b657a93ca4aa28758b75d71bcb3135275771724",
  documentRoot ? "main.typ",
  typstPackagesSrc,
  ...
}@attrs:
let
  typst-packages-fetched = stdenv.mkDerivation {
    inherit src;
    name = "typst-packages";

    buildInputs = [ typst ];

    outputHash = packagesHash;

    dontBuild = true;

    installPhase = ''
      export XDG_CACHE_HOME="$(mktemp -d)"
      typst compile "${documentRoot}"

      mkdir -p $out
      cp -r "$XDG_CACHE_HOME/typst/packages" "$out"
    '';
  };
  typst-packages-src = symlinkJoin {
    name = "typst-packages-src";
    paths = [
      "${typstPackagesSrc}/packages"
      # more typst packages can be added here
    ];
  };
  typst-packages-cache = stdenv.mkDerivation {
    name = "typst-packages-cache";
    src = typst-packages-src;
    dontBuild = true;
    installPhase =
      ''
        mkdir -p "$out/typst/packages"
        cp -LR --reflink=auto --no-preserve=mode -t "$out/typst/packages" "$src"/*
      ''
      + postPackagePhase;
  };
  font-paths = fontPaths;
  generateFontCommands = builtins.map (x: "cp -r " + x + " $out");
  font-packages = stdenv.mkDerivation {
    name = "fonts";
    phases = [ "installPhase" ];
    installPhase =
      ''
        mkdir -p $out
      ''
      + builtins.concatStringsSep "\n" (generateFontCommands font-paths);
  };
in
stdenv.mkDerivation {
  inherit
    name
    pname
    version
    src
    buildInputs
    ;

  XDG_CACHE_HOME = typst-packages-cache;
  SOURCE_DATE_EPOCH = unixTime;

  nativeBuildInputs = [ typst ] ++ nativeBuildInputs;

  buildPhase = ''
    export TYPST_FONT_PATHS=${font-packages}
    typst compile "${documentRoot}" "main.pdf"
  '';

  installPhase = ''
    install -Dm744 main.pdf $out/main.pdf
  '';
}
