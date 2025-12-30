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
      }: let
        speakeasyWrapped = pkgs.writeShellScriptBin "speakeasy" ''
          export GOWORK=off
          SPEAKEASY_HOME="$HOME/.speakeasy"
          if [[ -d "$SPEAKEASY_HOME" ]]; then
            LATEST_VERSION=$(${pkgs.coreutils}/bin/ls -1 "$SPEAKEASY_HOME" 2>/dev/null | ${pkgs.gnugrep}/bin/grep -E '^[0-9]+\.[0-9]+' | ${pkgs.coreutils}/bin/sort -V | ${pkgs.coreutils}/bin/tail -1)
            if [[ -n "$LATEST_VERSION" && -x "$SPEAKEASY_HOME/$LATEST_VERSION/bin/speakeasy" ]]; then
              exec "$SPEAKEASY_HOME/$LATEST_VERSION/bin/speakeasy" "$@"
            fi
          fi
          exec ${pkgs.speakeasy-cli}/bin/speakeasy "$@"
        '';
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Speakeasy CLI (wrapped to prefer local updates)
            speakeasyWrapped

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
