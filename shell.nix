with import <nixpkgs> {};

let
  devProxy = pkgs.writeShellScriptBin "devProxy" ''
  echo "🚀 make image API dev proxy";
  '';
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    pkgs.nodejs-16_x
    pkgs.yarn
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-format
    devProxy
  ];
}