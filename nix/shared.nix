let
  pkgs = import (fetchTarball {
    name = "nixpkgs-23.05-darwin-2023-10-05";
    url = "https://github.com/NixOS/nixpkgs/archive/1e9c7c0203be.tar.gz";
    sha256 = "10qbybc9k3dj1xap9n0i3z7pc3svzwhclgsyfzzsf8cfh8l518pn";
  }) { };

in { pkgs = pkgs; }
