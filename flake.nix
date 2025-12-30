{
  description = "Factify Go SDK - Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ {
    flake-parts,
    systems,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import systems;

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Speakeasy CLI
            speakeasy-cli

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
      };
    };
}
