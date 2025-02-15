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

  "gab@plo" = home-manager.lib.homeManagerConfiguration {
    inherit extraSpecialArgs pkgs;
    modules = [
      sops-nix.homeManagerModules.sops
      ../users/gab/plo
    ];
  };

  "gaby@plo" = home-manager.lib.homeManagerConfiguration {
    inherit extraSpecialArgs pkgs;
    modules = [../users/gaby/plo];
  };

  "gabrielad@gcd" = home-manager.lib.homeManagerConfiguration {
    inherit extraSpecialArgs pkgs;
    modules = [../users/gabrielad/gcd];
  };
}
