# parts/nixos.nix
{
  inputs,
  sops-nix,
  ...
}: let
  specialArgs = {
    inherit inputs sops-nix;
  };
in {
  flake.nixosModules = import ../modules/nixos;

  flake.nixosConfigurations = import ../nixosConfigurations {
    inherit (inputs) nixpkgs;
    inherit specialArgs;
  };
}
