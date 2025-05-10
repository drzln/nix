# nixosConfigurations/default.nix
{
  nixpkgs,
  specialArgs,
}: {
  plo = nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "x86_64-linux";
    modules = [
      ./plo/configuration.nix
    ];
  };
}
