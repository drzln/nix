# parts/home.nix
{inputs, ...}: {
  flake.homeManagerModules = import ../modules/home-manager;

  flake.homeConfigurations = import ../homeConfigurations {
    inherit (inputs) nixpkgs home-manager sops-nix;
    extraSpecialArgs = {
      inherit inputs;
    };
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = [];
      config.allowUnfree = true;
    };
  };
}
