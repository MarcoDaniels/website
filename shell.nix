let
    nixpkgs = fetchTarball {
        name = "NixOS-unstable-23-01-2022";
        url = "https://github.com/NixOS/nixpkgs/archive/30daa988f10.tar.gz";
        sha256 = "0zh3rbmzyv8d57fn22vfzi8b1di5daqwdrd6j1ayd5p1rh2vk59m";
    };

    pkgs = import nixpkgs {};

    devProxy = pkgs.writeShellScriptBin "devProxy" ''
        echo "🚀 make image API dev proxy";
    '';

in pkgs.mkShell {
    buildInputs = [
        pkgs.nodejs-16_x
        pkgs.yarn
        pkgs.elmPackages.elm
        pkgs.elmPackages.elm-format
        devProxy
    ];
}