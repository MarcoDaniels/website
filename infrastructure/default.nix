let
  pkgs = import (import ../nix/pin.nix).nixpkgs { };

  mkLambda =
    { srcs ? ./elm-srcs.nix, src, name, srcdir, targets, registryDat }:
    pkgs.stdenv.mkDerivation {
      inherit name src;

      buildInputs = [ pkgs.elmPackages.elm pkgs.nodePackages.uglify-js ];

      buildPhase = pkgs.elmPackages.fetchElmDeps {
        elmPackages = import srcs;
        elmVersion = "0.19.1";
        inherit registryDat;
      };

      installPhase = let
        elmfile = module:
          "${srcdir}/${builtins.replaceStrings [ "." ] [ "/" ] module}.elm";
        extension = "js";
      in ''
        ${pkgs.lib.concatStrings (map (module: ''
          echo "compiling ${elmfile module}"
          elm make ${elmfile module} --output $out/${module}.${extension}
            echo "minifying ${elmfile module}"
            uglifyjs $out/${module}.${extension} --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
                | uglifyjs --mangle --output $out/${module}.${extension}
            cp ./infrastructure/lambda/index.js $out/index.js
        '') targets)}
      '';
    };

in mkLambda {
  name = "website-lambda-0.1.0";
  srcs = ../nix/elm-srcs.nix;
  src = ../.;
  registryDat = ../nix/registry.dat;
  targets = [ "OriginRequest" ];
  srcdir = "./infrastructure/lambda";
}
