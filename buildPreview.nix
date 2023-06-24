let pkgs = (import ./nix/shared.nix).pkgs;

in pkgs.stdenv.mkDerivation {
  name = "marco-daniels-preview";
  version = "0.0.1";
  src = ./.;

  buildInputs = [ pkgs.elmPackages.elm pkgs.nodePackages.uglify-js ];

  configurePhase = pkgs.elmPackages.fetchElmDeps {
    elmPackages = import ./nix/elm-srcs.nix;
    registryDat = ./nix/registry.dat;
    elmVersion = "0.19.1";
  };

  installPhase = ''
    ${pkgs.elmPackages.elm}/bin/elm make --optimize cockpit/Preview.elm --output=$out/preview/preview.js
    ${pkgs.nodePackages.uglify-js}/bin/uglifyjs $out/preview/preview.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
        | ${pkgs.nodePackages.uglify-js}/bin/uglifyjs --mangle --output $out/preview/preview.js
    cp $src/cockpit/Preview.html $out/preview/index.html
  '';
}
