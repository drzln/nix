# nixosConfigurations/default.nix
{
  nixpkgs,
  specialArgs,
}: {
  plo = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = specialArgs;
    modules = [
      ./plo/configuration.nix
    ];
  };
}
