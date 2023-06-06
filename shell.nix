let
  pkgs = (import ./nix/shared.nix).pkgs;
  jsHandler = (import ./nix/shared.nix).jsHandler;

  cockpitProxy = let
    proxyName = "cockpit-proxy";
    proxyVersion = "0.0.1";
    proxySrc = fetchGit {
      url = "git@github.com:MarcoDaniels/cockpit-cms-proxy.git";
      rev = "36d58329d0972d372addbeac883e4c925cc017ca";
    };
    proxyElm = pkgs.stdenv.mkDerivation {
      name = "${proxyName}-elm-dep";
      version = proxyVersion;
      src = proxySrc;
      buildInputs = [ pkgs.elm2nix pkgs.nix pkgs.cacert ];
      buildPhase = ''
        ${pkgs.elm2nix}/bin/elm2nix convert > default.nix
        ${pkgs.elm2nix}/bin/elm2nix snapshot
      '';
      installPhase = ''
        mkdir -p $out
        cp default.nix registry.dat $out
      '';
    };
  in pkgs.stdenv.mkDerivation {
    name = proxyName;
    version = proxyVersion;
    src = proxySrc;
    buildInputs = [ pkgs.elmPackages.elm ];
    configurePhase = pkgs.elmPackages.fetchElmDeps {
      elmPackages = import proxyElm;
      elmVersion = "0.19.1";
      registryDat = "${proxyElm}/registry.dat";
    };
    buildPhase = ''
      elm make --optimize src/Main.elm --output=dist/elm.js
      sed -e '1i\#!/usr/bin/env node' src/index.js > dist/${proxyName}
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp -a dist/. $out/bin/
      chmod +x $out/bin/${proxyName}
    '';
  };

  # concurrently Pages with Proxy & Preview
  start = pkgs.writeShellScriptBin "start" ''
    ${pkgs.concurrently}/bin/concurrently "yarn start" "${cockpitProxy}/bin/cockpit-proxy"
  '';

  ciBuild = pkgs.writeShellScriptBin "ciBuild" ''
    ${pkgs.yarn}/bin/yarn
    ${pkgs.yarn}/bin/yarn build
  '';

  # TODO: build preview should be a derivation
  buildPreview = pkgs.writeShellScriptBin "buildPreview" ''
    ${pkgs.elmPackages.elm}/bin/elm make --optimize cockpit/Preview.elm --output=preview/preview.js
    cp cockpit/Preview.html preview/index.html
  '';

  # to include flags: buildLambda AssetRequest "{flags:{token:'123',domain:'abc'}}"
  buildLambda = pkgs.writeScriptBin "buildLambda" ''
    ${pkgs.elmPackages.elm}/bin/elm make infrastructure/lambda/src/$1.elm --output infrastructure/lambda/result/$1/elm.js
    ${jsHandler}/bin/jsHandler $1 infrastructure/lambda/result/$1/index.js $2
  '';

  testLambda = pkgs.writeScriptBin "testLambda" ''
    #!/usr/bin/env node
    const fs = require('fs')
    const lambda = process.argv[2]
    const testPayload = process.argv[3]
    const {handler} = require("${
      toString ./.
    }/infrastructure/lambda/result/" + lambda)
    const payload = JSON.parse(fs.readFileSync("${
      toString ./.
    }/tests/" + testPayload + ".json"))

    logJSON = (_, content) =>
        console.log(JSON.stringify(content, null, 4))

    handler(payload, "", logJSON)
  '';

in pkgs.mkShell {
  buildInputs = [
    pkgs.nixfmt
    pkgs.terraform
    pkgs.nodejs-16_x
    pkgs.concurrently
    pkgs.yarn
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-format
    pkgs.elmPackages.elm-test
    pkgs.elm2nix

    ciBuild
    testLambda
    jsHandler
    buildLambda
    start
    buildPreview
  ];
}
