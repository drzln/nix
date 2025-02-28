{
  description = "drzzln systems";

  inputs = {
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
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
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
    ...
  } @ inputs: let
    inherit inputs self;
    overlays =
      import ./overlays/default.nix
      ++ builtins.attrValues sops-nix.overlays
      ++ [
        (final: prev: {nixhashsync = nixhashsync.packages.${prev.system}.default;})
      ];

    requirements = {inherit inputs self;};
    specialArgs = {inherit requirements;};

    mkPkgs = system:
      import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    nixos-modules = import ./modules/nixos;
  in {
    packages = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = mkPkgs system;
    in {
      neovim = pkgs.callPackage ./packages/neovim {};
      nixhashsync = nixhashsync.packages.${system}.default;
      kid = pkgs.runCommand "run-kid" {} ''
        mkdir -p $out/bin

        # Generate QEMU run script
        cat > $out/bin/run-kid << EOF
        #!/bin/sh

        # if [ ! -f nixos.qcow2 ]; then
        #   qemu-img create -f qcow2 nixos.qcow2 20G
        # fi

        # qemu-system-x86_64 \\
        #   -accel hvf \\
        #   -m 4096 \\
        #   -smp 2 \\
        #   -drive file=nixos.qcow2,if=virtio \\
        #   -net nic,model=virtio \\
        #   -net user,hostfwd=tcp::2222-:22 \\
        #   -nographic
        qemu-system-x86_64 \
          -accel hvf \
          -cpu host \
          -m 4096 \
          -smp 2 \
          -drive file=nixos.qcow2,if=virtio \
          -net nic,model=virtio \
          -net user,hostfwd=tcp::2222-:22 \
          -nographic
        EOF

        chmod +x $out/bin/run-kid
      '';
    });

    homeManagerModules = import ./modules/home-manager;
    nixosModules = nixos-modules;

    homeConfigurations = import ./homeConfigurations {
      inherit home-manager sops-nix nixpkgs;
      extraSpecialArgs = specialArgs;
      pkgs = mkPkgs "x86_64-linux";
    };

    nixosConfigurations = import ./nixosConfigurations {
      inherit nixpkgs home-manager sops-nix specialArgs;
    };

    darwinConfigurations = import ./darwinConfigurations {
      inherit
        nix-darwin
        home-manager
        inputs
        ;
      # extraSpecialArgs = specialArgs;
      # pkgs = mkPkgs "x86_64-darwin";
      darwin-pkgs = mkPkgs "x86_64-darwin";
    };
  };
}
