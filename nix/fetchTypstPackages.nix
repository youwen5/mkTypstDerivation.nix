# a "fetcher" for typst packages
#
# brief explanation: the typst package manager is experimental and very
# bare-bones, and the developers have been explicit about not wanting an easily
# parsable "package.lock" or even a "packages.toml" for specifying
# dependencies. thus the only way to pre-fetch typst packages is

# 1. download the ENTIRE typst packages repository (>= 600mb, growing, massive
# waste of space)

# 2. use sparseCheckout to selectively download only required packages (more
# reasonable, but because of nested dependencies, kind of annoying to use)

# 3. run the typst compiler in a FOD w/ network access, allow it to install the
# packages, and then hash them and copy them out.
#
# below is a proof-of-concept of #3. there may be reproducibility issues i am
# not aware about, but they will arise from hash mismatches.
{
  stdenvNoCC,
  typst,
}:
{
  documentRoot ? "main.typ",
  src,
  hash ? "",
  extraPackages ? null,
  stdenv ? stdenvNoCC,
}:
stdenv.mkDerivation {
  src = src;
  name = "typst-packages-cache";

  buildInputs = [ typst ];

  outputHashAlgo = "sha256";
  outputHashMode = "nar";

  outputHash = hash;

  dontBuild = true;

  installPhase =
    ''
      export XDG_CACHE_HOME="$(mktemp -d)"
      mkdir -p "$XDG_CACHE_HOME/typst/packages"
    ''
    + (
      if (extraPackages != null) then
        ''
          cp -LR --reflink=auto --no-preserve=mode -t "$XDG_CACHE_HOME/typst/packages" "${extraPackages}"/*
        ''
      else
        ""
    )
    + ''
      typst compile "${documentRoot}"

      mkdir -p $out/typst
      cp -r "$XDG_CACHE_HOME/typst/packages" "$out/typst"
    '';
}
