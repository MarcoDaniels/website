let
  pkgs = import (import ./nix/pin.nix).nixpkgs { };

  devProxy = pkgs.writeScriptBin "devProxy" ''
    #!/usr/bin/env node
    const http = require('http')
    const url = require('url')
    const https = require('https')

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
                res.writeHead(backend_res.statusCode, backend_res.headers)
                backend_res.on('data', (chunk) => {
                    res.write(chunk)
                })
                backend_res.on('end', () => {
                    res.end()
                })
            })

            req.on('data', (chunk) => {
                backend_req.write(chunk)
            })

            req.on('end', () => {
                backend_req.end()
            })
        }
    })

    proxy.listen(8000)
    console.log(`running dev in http://localhost:8000`)
  '';

in pkgs.mkShell {
  buildInputs = [
    pkgs.nixfmt
    pkgs.terraform
    pkgs.nodejs-16_x
    pkgs.yarn
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-format
    pkgs.elmPackages.elm-test
    pkgs.elm2nix
    devProxy
  ];
}
