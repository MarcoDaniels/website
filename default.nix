# TODO: nix will be used only for development for now
let
    pkgs = import (import ./nix/pin.nix).nixpkgs {};

    yarnPkg = pkgs.yarn2nix-moretea.mkYarnPackage {
        name = "marco-daniels";
        packageJSON = ./package.json;
        src = ./.;
        yarnLock = ./yarn.lock;
        publishBinsFor = ["elm-pages"];
    };
in pkgs.stdenv.mkDerivation {
    name = "marco-daniels";
    src = pkgs.lib.cleanSource ./.;

    buildInputs = [
        pkgs.elmPackages.elm
        pkgs.elmPackages.elm-format
        pkgs.yarn
        yarnPkg
    ];

    patchPhase = ''
        rm -rf elm-stuff
        ln -sf ${yarnPkg}/node_modules .
    '';

    shellHook = ''
        ln -fs ${yarnPkg}/node_modules .
    '';

    configurePhase = pkgs.elmPackages.fetchElmDeps {
        elmPackages = import ./nix/elm-srcs.nix;
        registryDat = ./nix/registry.dat;
        elmVersion  = "0.19.1";
    };

    # Error: EROFS: read-only file system
    installPhase = ''
        export out=/tmp/foo
        mkdir -p $out
        elm-pages build
    '';
}