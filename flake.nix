# flake.nix
{
  description = "drzzln nix configurations";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:LnL7/nix-darwin";
    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland";
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    nix-kubernetes.url = "github:drzln/nix-kubernetes";
    stylix.url = "github:danth/stylix";
    nix-security-modules = {
      url = "github:michaelBelsanti/nix-security-modules";
      flake = false;
    };
    tangerinixos = {
      url = "github:Pamplemousse/tangerinixos";
      flake = false;
    };

    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./parts/overlays.nix
        ./parts/packages.nix
        ./parts/nixos.nix
        ./parts/home.nix
        ./parts/darwin.nix
      ];
    };
}
