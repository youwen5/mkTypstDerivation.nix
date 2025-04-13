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
          fetchTypstPackages = pkgs.callPackage ./fetchTypstPackages.nix { };
        in
        {
          pack = fetchTypstPackages {
            src = ./test-document;
            documentRoot = "main.typ";

            extraPackages =
              let
                # example of using a custom typst package not published to the package repository
                # (this is my personal template)
                # explanation: first we download the repository containing the
                # template, and then set up a directory structure resembling
                # what Typst expects
                # ($XDG_CACHE_HOME/typst/packages/{NAMESPACE}/{TEMPLATE}/{VERSION})
                zenTyp = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
                  pname = "zen-typ-package";
                  version = "0.5.0";
                  src = pkgs.fetchFromGitHub {
                    owner = "youwen5";
                    repo = "zen.typ";
                    tag = "v${finalAttrs.version}";
                    hash = "sha256-oyfLwdzzvAojFkVcqSYI8Z/fz0O3n+jCtkeD4tzjszk=";
                  };
                  dontBuild = true;
                  installPhase = ''
                    mkdir -p "$out/packages/youwen/zen/0.5.0"
                    cp -r typst/* "$out/packages/youwen/zen/0.5.0"
                  '';
                });
              in
              pkgs.symlinkJoin {
                name = "typst-packages-src";
                paths = [
                  # more typst packages can be added here
                  "${zenTyp}/packages"
                ];
              };

            hash = "sha256-R2165yC67Z0sK9r29mqE0AQm/VOWeG36bXSXTMLQ3vg=";
          };
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
