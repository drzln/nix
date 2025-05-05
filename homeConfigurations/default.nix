{
  home-manager,
  sops-nix,
  extraSpecialArgs,
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
