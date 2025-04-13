{
  stdenvNoCC,
  typst,
}:
{
  name ? null,
  pname ? null,
  version ? null,
  src,
  unixTime ? 0,
  fontPaths ? [ ],
  typstPackages ? null,
  stdenv ? stdenvNoCC,
  nativeBuildInputs ? [ ],
  buildInputs ? [ ],
  documentRoot ? "main.typ",
  ...
}:
let
  generateFontCommands = builtins.map (x: "cp -r " + x + " $out");
  font-packages = stdenv.mkDerivation {
    name = "fonts";
    phases = [ "installPhase" ];
    installPhase =
      ''
        mkdir -p $out
      ''
      + builtins.concatStringsSep "\n" (generateFontCommands fontPaths);
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

  XDG_CACHE_HOME = typstPackages;
  SOURCE_DATE_EPOCH = unixTime;
  TYPST_FONT_PATHS = font-packages;

  nativeBuildInputs = [ typst ] ++ nativeBuildInputs;

  buildPhase = ''
    typst compile "${documentRoot}" "main.pdf"
  '';

  installPhase = ''
    install -Dm744 main.pdf $out/main.pdf
  '';
}
