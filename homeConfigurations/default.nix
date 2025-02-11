{ home-manager, sops-nix, extraSpecialArgs, linux-pkgs }: {
  "luis@plo" = home-manager.lib.homeManagerConfiguration {
    inherit extraSpecialArgs;
    pkgs = linux-pkgs;
    modules = [
      sops-nix.homeManagerModules.sops
      ../users/luis/plo
    ];
  };

  "gab@plo" = home-manager.lib.homeManagerConfiguration {
    inherit extraSpecialArgs;
    pkgs = linux-pkgs;
    modules = [
      sops-nix.homeManagerModules.sops
      ../users/gab/plo
    ];
  };

  "gaby@plo" = home-manager.lib.homeManagerConfiguration {
    inherit extraSpecialArgs;
    pkgs = linux-pkgs;
    modules = [ ../users/gaby/plo ];
  };

  "gabrielad@gcd" = home-manager.lib.homeManagerConfiguration {
    inherit extraSpecialArgs;
    pkgs = linux-pkgs;
    modules = [ ../users/gabrielad/gcd ];
  };
}

