let
  pkgs = (import ./nix/shared.nix).pkgs;
  jsHandler = (import ./nix/shared.nix).jsHandler;

  cockpitProxy = let
      proxyName = "cockpit-proxy";
      proxyVersion = "2.0.0";
      nixGleamSrc = pkgs.stdenv.mkDerivation {
          name = "nix-gleam";
          src = fetchGit {
            url = "https://github.com/arnarg/nix-gleam.git";
            rev = "d1d2d6bcc5be6ea6a2d31e48aa55e7ea3bd41a1f";
          };
          installPhase = ''
             mkdir -p $out
             cp $src/builder/default.nix $out
          '';
      };
      nixGleam = (pkgs.callPackage nixGleamSrc {});
    in nixGleam.buildGleamApplication {
      pname = proxyName;
      version = proxyVersion;
      src = fetchGit {
        url = "https://github.com/MarcoDaniels/cockpit-cms-proxy.git";
        ref = "refs/tags/v${proxyVersion}";
      };
    };

  dot2Env = pkgs.stdenv.mkDerivation {
    name = "dot2Env";
    version = "0.0.1";
    src = fetchGit {
      url = "https://github.com/MarcoDaniels/scripts.git";
      rev = "38119e17ab198abe0fdf4ae2e3222596925f4b00";
    };
    installPhase = ''
      mkdir -p $out/bin
      cp $src/dot2Env.sh $out/bin/dot2Env
      chmod +x $out/bin/dot2Env
    '';
    doCheck = true;
  };

  # concurrently Pages with Proxy & Preview
  start = pkgs.writeShellScriptBin "start" ''
    ${pkgs.concurrently}/bin/concurrently "${pkgs.elmPackages.elm-pages}/bin/elm-pages dev" cockpit_cms_proxy
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
    pkgs.nodejs_18
    pkgs.concurrently
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-format
    pkgs.elmPackages.elm-test
    pkgs.elmPackages.elm-pages
    pkgs.elm2nix

    cockpitProxy
    dot2Env
    testLambda
    jsHandler
    buildLambda
    start
  ];
}
