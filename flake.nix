# flake.nix
{
  description = "drzzln nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-security-modules = {
      url = "github:michaelBelsanti/nix-security-modules";
      flake = false;
    };
    tangerinixos = {
      url = "github:Pamplemousse/tangerinixos";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager/master";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    stylix.url = "github:danth/stylix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    nix-darwin,
    sops-nix,
    ...
  }: let
    overlays = builtins.attrValues sops-nix.overlays ++ import ./overlays ++ [
      (final: prev: {
        # extra packages can go here
      })
    ];

    mkPkgs = system: import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

    basePackages = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = mkPkgs system;
    in {
      neovim = pkgs.callPackage ./pkgs/neovim {};
    });

    requirements = { inherit inputs self; };

    specialArgs = {
      inherit inputs self requirements;
      packages = basePackages;
    };
  in {
    inherit basePackages;
    packages = basePackages;

    nixosConfigurations = import ./nixosConfigurations {
      inherit nixpkgs home-manager sops-nix specialArgs;
    };

    nixosModules = import ./modules/nixos;

    homeManagerModules = import ./modules/home-manager;

    homeConfigurations = import ./homeConfigurations {
      inherit home-manager sops-nix nixpkgs;
      extraSpecialArgs = specialArgs;
      pkgs = mkPkgs "x86_64-linux";
    };

    darwinConfigurations = import ./darwinConfigurations {
      pkgs = mkPkgs "aarch64-darwin";
      inherit nix-darwin home-manager inputs;
    };
  };
}

