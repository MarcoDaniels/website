let
  pkgs = import (import ../nix/pin.nix).nixpkgs { };

  jsHandler = pkgs.writeShellScriptBin "jsHandler" ''
    echo "const {Elm} = require('./elm');
    const app = Elm.$1.init();
    exports.handler = (event, context, callback) => {
        app.ports.inputEvent.send(event);
        app.ports.outputEvent.subscribe((output) =>
            callback(null, output)
        );
    }
    " > $2
  '';

  mkLambda = { srcs ? ./elm-srcs.nix, src, name, srcdir, targets, registryDat }:
    pkgs.stdenv.mkDerivation {
      inherit name src;

      buildInputs =
        [ pkgs.elmPackages.elm pkgs.nodePackages.uglify-js jsHandler ];

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
          elm make ${elmfile module} --optimize --output $out/${module}/elm.${extension}
          echo "minifying ${elmfile module}"
          uglifyjs $out/${module}/elm.${extension} --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
            | uglifyjs --mangle --output $out/${module}/elm.${extension}
          ${jsHandler}/bin/jsHandler ${module} $out/${module}/index.${extension}
        '') targets)}
      '';
    };

in mkLambda {
  name = "website-lambdas-1.0.0";
  srcs = ../nix/elm-srcs.nix;
  src = ../.;
  registryDat = ../nix/registry.dat;
  targets = [ "OriginRequest" ];
  srcdir = "./infrastructure/lambda";
}

