# parts/nixos.nix
{inputs, ...}: let
  specialArgs = {
    inherit inputs;
  };
in {
  flake.nixosModules = import ../modules/nixos;

  flake.nixosConfigurations = import ../nixosConfigurations {
    inherit (inputs) nixpkgs home-manager sops-nix;
    inherit specialArgs;
  };
}
