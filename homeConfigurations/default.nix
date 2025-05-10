# homeConfigurations/default.nix
{
  extraSpecialArgs,
  home-manager,
  sops-nix,
  pkgs,
  ...
}: {
  "luis@plo" = home-manager.lib.homeManagerConfiguration {
    inherit extraSpecialArgs pkgs;
    modules = [
      sops-nix.homeManagerModules.sops
      ../users/luis/plo
    ];
  };
}
