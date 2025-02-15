{
  description = "drzzln systems";

  inputs = {
    nixhashsync = {
      url = "github:gahbdias/NixHashSync";
    };

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

    rednix = {
      url = "github:redcode-labs/RedNix";
    };

    home-manager = {
      url = "github:nix-community/home-manager?branch=master";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin?branch=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    stylix = {
      url = "github:danth/stylix";
    };

    nixified-ai = {
      url = "github:nixified-ai/flake";
    };
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    home-manager,
    nix-darwin,
    hyprland,
    hyprland-plugins,
    stylix,
    sops-nix,
    nixhashsync,
    pwnixos,
    nix-security-modules,
    tangerinixos,
    rednix,
    nixified-ai,
    ...
  } @ inputs: let
    inherit (self) outputs;
    overlays =
      import ./overlays/default.nix
      ++ builtins.attrValues sops-nix.overlays
      ++ [
        (final: prev: {
          nixhashsync = nixhashsync.packages.${prev.system}.default;
        })
      ];
    requirements = {inherit inputs outputs;};
    specialArgs = {
      inherit requirements;
    };
    extraSpecialArgs = specialArgs;

    shared-pkg-attributes = {
      inherit overlays;
      config.allowUnfree = true;
    };

    darwin-pkgs =
      import nixpkgs
      {
        system = "x86_64-darwin";
        overlays = shared-pkg-attributes.overlays;
      }
      // shared-pkg-attributes;

    linux-pkgs =
      import nixpkgs
      {
        system = "x86_64-linux";
        overlays = shared-pkg-attributes.overlays;
      }
      // shared-pkg-attributes;

    local-nixos-modules = import ./modules/nixos;
    external-nixos-modules = {};
    nixos-modules = local-nixos-modules // external-nixos-modules;
  in {
    packages = flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = shared-pkg-attributes.overlays;
        };
      in {
        neovim_drzln = pkgs.callPackage ./packages/neovim {};
        nixhashsync = nixhashsync.packages.${system}.default;
      }
    );

    homeManagerModules = import ./modules/home-manager;
    nixosModules = nixos-modules;

    homeConfigurations = import ./homeConfigurations {
      inherit home-manager sops-nix extraSpecialArgs linux-pkgs;
    };

    nixosConfigurations = import ./nixosConfigurations {
      inherit nixpkgs specialArgs home-manager sops-nix;
    };

    darwinConfigurations = import ./darwinConfigurations {
      inherit nix-darwin home-manager inputs darwin-pkgs;
    };
  };
}
