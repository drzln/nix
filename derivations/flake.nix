###############################################################################
# expose your local packages via a flake
###############################################################################

{
  description = "local packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, utils, ... }: {
    # Generate a user-friendly version number
    version = builtins.substring 0 8 self.lastModifiedDate;

    # systems to support
    supportedSystems = [ "x86_64-linux" ];

    # exposed packages
    packages = {
      x86_64-linux =
        with import nixpkgs { system = "x86_64-linux"; };
        stdenv.mkDerivation {
          name = "hello";
        };
    };
  };
}