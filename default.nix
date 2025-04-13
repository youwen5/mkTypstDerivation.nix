{
  pkgs,
  typstCompiler ? pkgs.typst,
}:
let
  c = pkgs.callPackage;
in
{
  mkTypstDerivation = c ./nix/mkTypstDerivation.nix { typst = typstCompiler; };
  fetchTypstPackages = c ./nix/fetchTypstPackages.nix { typst = typstCompiler; };
}
