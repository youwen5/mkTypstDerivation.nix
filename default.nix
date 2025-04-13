{
  mkTypstDerivation,
  liberation_ttf,
  zen-typ,
  flakeSelf,
  fetchFromGitHub,
  resolvePackagesPath,
}:
mkTypstDerivation {
  name = "lab01-writeup";
  src = ./.;
  postPackagePhase = ''
    mkdir -p $out/typst/packages/youwen/zen/0.5.0
    cp -LR --reflink=auto --no-preserve=mode -t "$out/typst/packages/youwen/zen/0.5.0" "${zen-typ}/typst"/*
  '';
  fontPaths = [
    "${liberation_ttf}/share/fonts/truetype/*"
  ];
  unixTime = builtins.toString flakeSelf.lastModified;

  typst-packages-src = fetchFromGitHub {
    owner = "typst";
    repo = "packages";
    rev = "7b657a93ca4aa28758b75d71bcb3135275771724";
    hash = "sha256-S746ZI5FIFu482AlaF0lDoxIOAgqF64gD/sYdAZUNjk=";
    sparseCheckout = resolvePackagesPath [
      "cetz-plot"
      "cetz"
      "showybox"
      "ctheorems"
      "codly"
      "codly-languages"
      "oxifmt"
    ];
  };
}
