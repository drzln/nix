{
  description = "drzzln nix configurations";
  inputs = {
    nix-kubernetes = {url = "github:drzln/nix-kubernetes";};
    nixhashsync = {url = "github:gahbdias/NixHashSync";};
    pwnixos.url = "github:exploitoverload/PwNixOS";
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
    rednix = {url = "github:redcode-labs/RedNix";};
    home-manager = {url = "github:nix-community/home-manager?branch=master";};
    nix-darwin = {
      url = "github:LnL7/nix-darwin?branch=master";
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
    stylix = {url = "github:danth/stylix";};
    nixified-ai = {url = "github:nixified-ai/flake";};
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    nix-darwin,
    sops-nix,
    nixhashsync,
    pwnixos,
    rednix,
    nixified-ai,
    nix-kubernetes,
    ...
  } @ inputs: let
    inherit inputs self;
    overlays =
      builtins.attrValues sops-nix.overlays
      ++ [
        (final: prev: {
          nixhashsync = nixhashsync.packages.${prev.system}.default;
        })
      ]
      ++ import ./overlays;
    mkPkgs = system:
      import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    requirements = {inherit inputs self;};
    specialArgs = {inherit requirements packages inputs;};
    nixosConfigurations = import ./nixosConfigurations {
      inherit nixpkgs home-manager sops-nix specialArgs inputs;
    };
    nixos-modules = import ./modules/nixos;
    darwin-pkgs = mkPkgs "aarch64-darwin";
    base-packages = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = mkPkgs system;
    in {
      neovim = pkgs.callPackage ./packages/neovim {};
    });
    packages = base-packages;
  in {
    inherit nixosConfigurations packages;
    homeManagerModules = import ./modules/home-manager;
    nixosModules = nixos-modules;
    homeConfigurations = import ./homeConfigurations {
      inherit home-manager sops-nix nixpkgs;
      extraSpecialArgs = specialArgs;
      pkgs = mkPkgs "x86_64-linux";
    };
    darwinConfigurations = import ./darwinConfigurations {
      inherit
        darwin-pkgs
        nix-darwin
        home-manager
        inputs
        ;
    };
  };
}
