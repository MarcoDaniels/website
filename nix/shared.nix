let
  pkgs = import (fetchTarball {
    name = "NixOS-unstable-23-01-2022";
    url = "https://github.com/NixOS/nixpkgs/archive/30daa988f10.tar.gz";
    sha256 = "0zh3rbmzyv8d57fn22vfzi8b1di5daqwdrd6j1ayd5p1rh2vk59m";
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
