let
  pkgs = (import ./nix/shared.nix).pkgs;
  jsHandler = (import ./nix/shared.nix).jsHandler;

  devProxy = pkgs.writeScriptBin "devProxy" ''
    #!/usr/bin/env node
    const http = require('http')
    const url = require('url')
    const https = require('https')
    const {Elm} = require('${toString ./.}/dist/proxy')
    const app = Elm.Proxy.init()

    const proxy = http.createServer((req, res) => {
        const request = url.parse(req.url)

        if (request.path.startsWith('/image/api/')) {
            const path = request.pathname.replace('/image/api', "")
            const host = (process.env.COCKPIT_BASE_URL).replace("https://", "")

            const options = {
                host: host,
                path: "/api/cockpit/image?token=" + process.env.COCKPIT_API_TOKEN + "&src=" + process.env.COCKPIT_BASE_URL + "/storage/uploads" + path + "&" + request.query,
                method: req.method,
                headers: {...req.headers, host: host},
            }

            https.get(options, (backend_res) => {
                res.writeHead(backend_res.statusCode, backend_res.headers)
                backend_res.pipe(res, {end: true})
            })
        } else {
            const options = {
                host: request.hostname,
                port: 1234,
                path: request.path,
                method: req.method,
                headers: req.headers,
            }

            const backend_req = http.request(options, (backend_res) => {
                const caller = (data) => {
                    res.writeHead(backend_res.statusCode, data.headers)
                    app.ports.writeOutput.unsubscribe(caller)
                }
                app.ports.writeOutput.subscribe(caller)
                app.ports.readInput.send({headers: backend_res.headers})

                backend_res.on('data', (chunk) => res.write(chunk))
                backend_res.on('end', () => res.end())
            })

            req.on('data', (chunk) => backend_req.write(chunk))
            req.on('end', () => backend_req.end())
        }
    })

    proxy.listen(8000)
    console.log(`running dev in http://localhost:8000`)
  '';

  # concurrently dev server with ElmProxy
  start = pkgs.writeShellScriptBin "start" ''
      elm make --optimize src/Proxy.elm --output=dist/proxy.js
      ${pkgs.concurrently}/bin/concurrently "yarn start" "devProxy"
  '';

  ciBuild = pkgs.writeShellScriptBin "ciBuild" ''
    ${pkgs.yarn}/bin/yarn
    ${pkgs.yarn}/bin/yarn build
  '';

  # TODO: separate dev and CI

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
    const {handler} = require("${toString ./.}/infrastructure/lambda/result/" + lambda)
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
  ];
}
