{
  description = "barebones flake for building a typst document";

  inputs = {
    nixpkgs = "github:nixos/nixpkgs/nixos-unstable";
    mkTypstDerivation = "github:youwen5/mkTypstDerivation.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      mkTypstDerivation,
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
          typstLib = import mkTypstDerivation { inherit pkgs; };
        in
        {
          default =
            let
              name = "my-document";
              documentRoot = "main.typ";
              src = ./.;
              typstPackages = typstLib.fetchTypstPackages {
                inherit src documentRoot;
                # don't forget to update this once you obtain it (by running
                # `nix build` and checking the build failure)
                hash = "";
              };
            in
            typstLib.mkTypstDerivation {
              inherit
                name
                documentRoot
                typstPackages
                src
                ;

              # add some additional fonts
              fontPaths = [
                "${pkgs.liberation_ttf}/share/fonts/truetype/*"
                # more fonts can be added
              ];
            };
        }
      );
    };
}
