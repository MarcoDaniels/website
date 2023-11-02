let
  pkgs = import (fetchTarball {
    name = "nixpkgs-23.05-darwin";
    url = "https://github.com/NixOS/nixpkgs/archive/fc541b860a28.tar.gz";
    sha256 = "0929i9d331zgv86imvsdzyfsrnr7zwhb7sdh8sw5zzsp7qsxycja";
  }) { };

  jsHandler = pkgs.writeShellScriptBin "jsHandler" ''
    echo "const {Elm} = require('./elm');
    const app = Elm.$1.init($3);
    exports.handler = (event, context, callback) => {
        const caller = (output) => {
            callback(null, output);
            app.ports.outputEvent.unsubscribe(caller);
        }
        app.ports.outputEvent.subscribe(caller);
        app.ports.inputEvent.send(event);
    } " > $2
  '';

in { pkgs = pkgs; jsHandler = jsHandler; }
