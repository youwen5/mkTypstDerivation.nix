{
  description = "cs24 at ucsb";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    zen-typ.url = "github:youwen5/zen.typ";
  };

  outputs =
    {
      self,
      nixpkgs,
      zen-typ,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          resolvePackagesPath = builtins.map (x: "packages/preview/" + x);
          mkTypstDerivation = pkgs.callPackage ./mkTypstDerivation.nix { };
        in
        {
          default = mkTypstDerivation {
            name = "test-doc";

            src = ./test-document;

            unixTime = builtins.toString self.lastModified;

            documentRoot = "main.typ";

            fontPaths = [
              "${pkgs.liberation_ttf}/share/fonts/truetype/*"
            ];

            postPackagePhase = ''
              mkdir -p $out/typst/packages/youwen/zen/0.5.0
              cp -LR --reflink=auto --no-preserve=mode -t "$out/typst/packages/youwen/zen/0.5.0" "${zen-typ}/typst"/*
            '';

            typstPackagesSrc = pkgs.fetchFromGitHub {
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
          };
        }
      );
    };
}
