{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        x11Libs = with pkgs.xorg; [
          libX11
          libXcursor
          libXrandr
          libXi
          libXinerama
          libXpresent
          libxcb
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              cargo
              libxkbcommon
              pkg-config
              bashInteractive
            ] ++ x11Libs;

          shellHook = ''
            export SHELL=${pkgs.bashInteractive}/bin/bash
            export LD_LIBRARY_PATH=${
              pkgs.lib.makeLibraryPath (
                x11Libs ++ [ pkgs.libxkbcommon ]
              )
            }:$LD_LIBRARY_PATH
          '';
        };
      }
    );
}
