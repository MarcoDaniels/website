let
  pkgs = import (import ../nix/pin.nix).nixpkgs { };

  jsHandler = pkgs.writeShellScriptBin "jsHandler" ''
    echo "const {Elm} = require('./elm');
    const app = Elm.$1.init($3);
    exports.handler = (event, context, callback) => {
        const caller = (output) => {
            callback(null, output);
            app.ports.outputEvent.unsubscribe(caller);
        }
        app.ports.outputEvent.subscribe(caller);
        app.ports.inputEvent.send(event);
    }" > $2
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
        ${pkgs.lib.concatStrings (map (target: ''
          echo "compiling ${elmfile target.module}"
          elm make ${
            elmfile target.module
          } --optimize --output $out/${target.module}/elm.${extension}
          echo "minifying ${elmfile target.module}"
          uglifyjs $out/${target.module}/elm.${extension} --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
            | uglifyjs --mangle --output $out/${target.module}/elm.${extension}
          ${jsHandler}/bin/jsHandler ${target.module} $out/${target.module}/index.${extension} ${target.flags}
        '') targets)}
      '';
    };

in mkLambda {
  name = "lambda-1.0.0";
  srcs = ../nix/elm-srcs.nix;
  src = ../.;
  registryDat = ../nix/registry.dat;
  targets = [
    {
      module = "WebsiteRequest";
      flags = "";
    }
    {
      module = "AssetRequest";
      flags = ''"{flags:{token:'""$"{token}"',assetURL:'""$"{assetURL}"'}}"'';
    }
  ];
  srcdir = "./infrastructure/lambda";
}

