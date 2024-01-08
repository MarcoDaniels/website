let
  pkgs = (import ./nix/shared.nix).pkgs;

  cockpitProxy = let
      proxyName = "cockpit-proxy";
      proxyVersion = "2.0.1";
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

  elmPostInstall = pkgs.writeShellScriptBin "elmPostInstall" ''
    ${pkgs.elm2nix}/bin/elm2nix convert > nix/elm-srcs.nix
    ${pkgs.elm2nix}/bin/elm2nix snapshot
    mv registry.dat nix/
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
    start
    elmPostInstall
  ];
}
