let
    pkgs = import (import ./nix/pin.nix).nixpkgs {};

    devProxy = pkgs.writeShellScriptBin "devProxy" ''
        echo "🚀 make image API dev proxy";
    '';

    buildLambda = pkgs.writeShellScriptBin "buildLambda" ''
       elm make infrastructure/lambda/OriginRequest.elm --optimize --output infrastructure/dist/OriginRequest.js
       cp infrastructure/lambda/index.js infrastructure/dist/index.js
    '';

    testLambda = pkgs.writeScriptBin "testLambda" ''
        #!/usr/bin/env node
        const {handler} = require("${toString ./.}/infrastructure/dist")

        const payload = {
            "Records": [
                {
                    "cf": {
                        "config": {
                            "distributionDomainName": "d111111abcdef8.cloudfront.net",
                            "distributionId": "EDFDVBD6EXAMPLE",
                            "eventType": "origin-request",
                            "requestId": "4TyzHTaYWb1GX1qTfsHhEqV6HUDd_BzoBZnwfnvQc_1oF26ClkoUSEQ=="
                        },
                        "request": {
                            "clientIp": "203.0.113.178",
                            "headers": {
                                "user-agent": [
                                    {
                                        "key": "User-Agent",
                                        "value": "Amazon CloudFront"
                                    }
                                ],
                                "cache-control": [
                                    {
                                        "key": "Cache-Control",
                                        "value": "no-cache, cf-no-cache"
                                    }
                                ]
                            },
                            "method": "GET",
                            "querystring": "",
                            "uri": "/"
                        }
                    }
                }
            ]
        }

        logJSON = (_, content) =>
            console.log(JSON.stringify(content, null, 4))

        handler(payload, "", logJSON)
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
        buildLambda
        testLambda
    ];
}