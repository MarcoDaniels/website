let
  pkgs = (import ./nix/shared.nix).pkgs;

  buildWebsite = pkgs.writeScriptBin "buildWebsite" ''
    ${pkgs.elmPackages.elm-pages}/bin/elm-pages build
  '';

in pkgs.mkShell {
  buildInputs = [
    buildWebsite
  ];
}
