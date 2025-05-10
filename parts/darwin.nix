# parts/darwin.nix
{inputs, ...}: {
  flake.darwinConfigurations = import ../darwinConfigurations {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      overlays = [];
      config.allowUnfree = true;
    };
    inherit (inputs) nix-darwin home-manager;
    inherit inputs;
  };
}
