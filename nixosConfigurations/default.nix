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
        services.openssh.enable = true;
        services.openssh.permitRootLogin = "yes";
        services.openssh.passwordAuthentication = true;
        users.users.ldesiqueira = {
          uid = 1002;
          isNormalUser = true;
          extraGroups = ["wheel"]; # Allow sudo
          password = "letmein";
        };
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
