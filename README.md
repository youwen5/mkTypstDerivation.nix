# mkTypstDerivation.nix

A tiny library for building Typst projects with Nix. Designed to drop straight
into an existing Typst document and require minimal maintenance.

## Features

- Easily compile a document with a minimal derivation that can handle fonts and packages for you.
- Download packages automatically. You only have to update one SRI hash
  whenever you add or remove packages. You don't have to maintain a separate
  list of Typst packages to fetch with Nix, it can be done automatically from
  your document.

## Use

Use `nix flake init -t github:youwen5/mkTypstDerivation.nix` to obtain a bare
minimum `flake.nix` to compile a Typst document with some packages and fonts.
The file is self-documenting!

## See also

- [Typix](https://github.com/loqusion/typix), a much more featureful library.
