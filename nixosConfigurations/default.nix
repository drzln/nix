{
  nixpkgs,
  specialArgs,
  home-manager,
  sops-nix,
}: {
  kid = nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "x86_64-linux";
    modules = [
      ../vms/main.nix
      ({...}: {
      })
      # /etc/nixos/configuration.nix
      # ../nodes/plo
      # home-manager.nixosModules.home-manager
      # sops-nix.nixosModules.sops
    ];
  };

  plo = nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "x86_64-linux";
    modules = [
      /etc/nixos/configuration.nix
      ../nodes/plo
      home-manager.nixosModules.home-manager
      sops-nix.nixosModules.sops
    ];
  };

  gcd = nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "x86_64-linux";
    modules = [
      /etc/nixos/configuration.nix
      ../nodes/gcd
      home-manager.nixosModules.home-manager
      sops-nix.nixosModules.sops
    ];
  };
}
