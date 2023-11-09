let
  pkgs = (import ./nix/shared.nix).pkgs;

  buildValidate = pkgs.writeScriptBin "buildValidate" ''
    if [ ! -f ./dist/elm.js ]; then
        echo "Elm build not found"
        exit 1
    fi
  '';

  buildWebsite = pkgs.writeScriptBin "buildWebsite" ''
    ${pkgs.elmPackages.elm-pages}/bin/elm-pages build --debug
    ${pkgs.elmPackages.elm-pages}/bin/elm-pages build || true
    ${buildValidate}/bin/buildValidate
  '';

in pkgs.mkShell {
  buildInputs = [
    buildWebsite
  ];
}
