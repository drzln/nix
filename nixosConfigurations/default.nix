{
  nixpkgs,
  specialArgs,
  home-manager,
  sops-nix,
  # inputs,
}: let
  finalSpecialArgs =
    specialArgs
    // {
      inherit nixpkgs;
      overlays = import ../overlays;
    };
in {
  kid = nixpkgs.lib.nixosSystem {
    specialArgs = finalSpecialArgs;
    system = "aarch64-linux";
    modules = [
      ../vms/main.nix
      ({...}: {
        # put more system config here
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
      home-manager.nixosModules.home-manager
      sops-nix.nixosModules.sops
      # inputs.nix-kubernetes.nixosModules.kubernetes
      /etc/nixos/configuration.nix
      ../nodes/plo
    ];
  };
}
