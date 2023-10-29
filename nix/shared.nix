let
  pkgs = import (fetchTarball {
    name = "nixpkgs-23.05-darwin-2023-10-05";
    url = "https://github.com/NixOS/nixpkgs/archive/1e9c7c0203be.tar.gz";
    sha256 = "10qbybc9k3dj1xap9n0i3z7pc3svzwhclgsyfzzsf8cfh8l518pn";
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
