# nixosConfigurations/default.nix
{
  nixpkgs,
  specialArgs,
}: {
  plo = nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "x86_64-linux";
    modules = [
      specialArgs.inputs.sops-nix.nixosModules.sops
      ../nodes/plo/configuration.nix
    ];
  };
}
