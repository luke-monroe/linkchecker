{
  description = "Python 3.12 dev environment for linkchecker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonEnv = pkgs.python312.withPackages (ps: with ps; [
          # Runtime dependencies
          requests
          dnspython
          beautifulsoup4

          # Build & packaging
          hatchling
          hatch-vcs

          # Testing & QA
          pytest
          pytest-xdist
          pytest-cov
          cryptography
          pyopenssl
          pyftpdlib
          tox
          flake8

          # Utilities
          pip
          virtualenv
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pythonEnv
          ];

          shellHook = ''
            echo "🐍 Python 3.12 linkchecker environment loaded"
            python --version
          '';
        };
      });
}
