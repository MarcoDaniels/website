let
    pkgs = import (import ./nix/pin.nix).nixpkgs {};

    devProxy = pkgs.writeShellScriptBin "devProxy" ''
        echo "🚀 make image API dev proxy";
    '';

in pkgs.mkShell {
    buildInputs = [
        pkgs.terraform
        pkgs.nodejs-16_x
        pkgs.yarn
        pkgs.elmPackages.elm
        pkgs.elmPackages.elm-format
        pkgs.elm2nix
        devProxy
    ];
}