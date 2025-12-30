{
  description = "Factify Go SDK - Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # Speakeasy CLI
          speakeasy

          # Go tooling
          go_1_23
          golangci-lint

          # Version control
          git
          gh

          # Utilities
          jq
        ];

        shellHook = ''
          echo "🚀 Factify Go SDK Development Environment"
          echo "Speakeasy: $(speakeasy --version 2>&1 | head -n1)"
          echo "Go: $(go version)"
        '';
      };
    });
}
