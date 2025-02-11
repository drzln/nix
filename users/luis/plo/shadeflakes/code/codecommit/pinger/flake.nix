{
  description = "base requirements for codecommit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = import nixpkgs { inherit system overlays; };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [
            gnumake
            docker-compose
            docker
            yq
            jq
            (python3.withPackages (ps: with ps; [
              git-remote-codecommit
              pre-commit
            ]))
          ];
          shellHook = ''
            export PATH=$PATH:${pkgs.git-remote-codecommit}/bin
            export PATH=$PATH:${pkgs.pre-commit}/bin
          '';
        };
      }
    );
}
