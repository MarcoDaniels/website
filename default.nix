{ token, url }:
let
  pkgs = (import ./nix/shared.nix).pkgs;

  yarnPkgs = pkgs.yarn2nix-moretea.mkYarnPackage {
    name = "yarnPkgs";
    version = "0.0.1";
    src = pkgs.nix-gitignore.gitignoreSource [ ] ./.;
    publishBinsFor = [ "elm-pages" "elm-review" "elm-optimize-level-2" ];
  };

in pkgs.stdenv.mkDerivation {
  name = "marco-daniels-website";
  version = "0.0.1";
  src = pkgs.nix-gitignore.gitignoreSource [ ] ./.;
  buildInputs = [ yarnPkgs pkgs.elmPackages.elm pkgs.yarn pkgs.nodejs-16_x ];

  COCKPIT_API_URL = url;
  COCKPIT_API_TOKEN = token;

  postUnpack = ''
    export HOME="$TMP"
  '';

  patchPhase = ''
    rm -rf elm-stuff
    ln -sf ${yarnPkgs}/node_modules .
  '';

  buildPhase = pkgs.elmPackages.fetchElmDeps {
    elmVersion = "0.19.1";
    elmPackages = import ./nix/elm-srcs.nix;
    registryDat = ./nix/registry.dat;
  };

  installPhase = ''
    mkdir -p $out dist
    ${yarnPkgs}/bin/elm-pages build
    cp -r dist/. $out/.
  '';
}
