# parts/nixos.nix
{inputs, ...}: {
  flake.nixosModules = import ../modules/nixos;

  flake.nixosConfigurations =
    {
      inherit (inputs) nixpkgs home-manager sops-nix;
      specialArgs = {
        inherit inputs;
      };
    }
    // import ../nixosConfigurations {
      inherit (inputs) nixpkgs home-manager sops-nix;
      specialArgs = {
        inherit inputs;
      };
    };
}
