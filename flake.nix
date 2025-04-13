{
  description = "a barebones library for compiling Typst documents using Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      # doesn't work on darwin yet because the typst package cache is in a
      # different location, sorry!
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          typstLib = import ./. { inherit pkgs; };

        in
        {
          # simplest example featuring fetching packages, using the
          # unequivocal-ams template
          simple-example =
            let
              name = "unequivocal-ams";
              documentRoot = "main.typ";
              src = ./tests/unequivocal-ams;
              typstPackages = typstLib.fetchTypstPackages {
                inherit src documentRoot;
                hash = "sha256-NKz/KQB3ZOJkTPiFdVKwyTUKo/AE/NjTIqBBauFmnWc=";
              };
            in
            typstLib.mkTypstDerivation {
              inherit
                name
                documentRoot
                typstPackages
                src
                ;
            };

          # a more complicated example, featuring custom fonts and a custom
          # package not in the typst packages repository
          complex-example =
            let
              src = ./tests/complex-example;
              name = "complex-example";
              documentRoot = "main.typ";
              typstPackages = typstLib.fetchTypstPackages {
                inherit name src documentRoot;

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
                      "${zenTyp}/packages"
                      # more custom packages can be added here
                    ];
                  };

                hash = "sha256-ukgjzbF9Tdvn/eTKUuX5AGHS4QeK00mzjFZ+aDj5axc=";
              };
            in
            typstLib.mkTypstDerivation {
              inherit
                typstPackages
                name
                src
                documentRoot
                ;

              # pass in the unix time, so #datetime.today() works properly
              unixTime = builtins.toString self.lastModified;

              fontPaths = [
                "${pkgs.liberation_ttf}/share/fonts/truetype/*"
                # more fonts can be added
              ];
            };
        }
      );
      templates.barebones = {
        path = ./templates/barebones;
        description = "barebones template for compiling a Typst document";
      };
      templates.default = self.templates.barebones;
    };
}
