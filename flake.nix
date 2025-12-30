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
              rustfmt
              rust-analyzer
              libxkbcommon
              vulkan-loader
              vulkan-headers
              vulkan-tools
              vulkan-validation-layers
              mesa
              pkg-config
              bashInteractive
            ] ++ x11Libs;

          shellHook = ''
            export SHELL=${pkgs.bashInteractive}/bin/bash
            export VK_LAYER_PATH="${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
            export LD_LIBRARY_PATH=${
              pkgs.lib.makeLibraryPath (
                x11Libs ++ [
                  pkgs.vulkan-loader
                  pkgs.vulkan-headers
                  pkgs.vulkan-tools
                  pkgs.vulkan-validation-layers
                  pkgs.mesa
                  pkgs.libxkbcommon
                ]
              )
            }:$LD_LIBRARY_PATH
          '';
        };
      }
    );
}
