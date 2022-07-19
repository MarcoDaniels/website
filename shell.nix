let
  pkgs = (import ./nix/shared.nix).pkgs;
  jsHandler = (import ./nix/shared.nix).jsHandler;

  devProxy = pkgs.writeScriptBin "devProxy" ''
    #!/usr/bin/env node
    const http = require('http')
    const https = require('https')
    const fs = require('fs')
    const {Elm} = require('${toString ./.}/dist/server')
    const app = Elm.Server.init({flags:{baseUrl:process.env.COCKPIT_BASE_URL,token:process.env.COCKPIT_API_TOKEN}})

    const responseCallback = (clientRes) => (serverResponse) => {
        const responseCaller = (data) => {
            clientRes.writeHead(serverResponse.statusCode, data.headers)
            serverResponse.pipe(clientRes, {end: true})

            app.ports.responseOutput.unsubscribe(responseCaller)
        }
        app.ports.responseOutput.subscribe(responseCaller)
        app.ports.responseInput.send({headers: serverResponse.headers})
    }

    http.createServer((incomingMessage, serverResponse) => {
        const serverCaller = (options) => {
            if (Boolean(options.fileSystem)) {
                fs.createReadStream(options.path).pipe(serverResponse)
            } else {
                const proxy = (Boolean(options.secure) ? https : http).request(options, responseCallback(serverResponse))
                incomingMessage.pipe(proxy, {end: true})
            }

            app.ports.serverOutput.unsubscribe(serverCaller)
        }
        app.ports.serverOutput.subscribe(serverCaller)
        app.ports.serverInput.send(incomingMessage)
    }).listen(8000)

    console.log(`running devProxy in http://localhost:8000`)
  '';

  # concurrently Pages with Proxy & Preview
  start = pkgs.writeShellScriptBin "start" ''
    ${pkgs.elmPackages.elm}/bin/elm make --optimize cockpit/Server.elm --output=dist/server.js
    ${pkgs.elmPackages.elm}/bin/elm make --optimize cockpit/Preview.elm --output=preview/preview.js
    cp cockpit/Preview.html preview/index.html
    ${pkgs.concurrently}/bin/concurrently "yarn start" "devProxy"
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
    devProxy
    ciBuild
    testLambda
    jsHandler
    buildLambda
    start
    buildPreview
  ];
}
