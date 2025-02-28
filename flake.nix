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

    nixosConfigurations = import ./nixosConfigurations {
      inherit nixpkgs home-manager sops-nix specialArgs;
    };

    mkPkgs = system:
      import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    nixos-modules = import ./modules/nixos;
    packages = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = mkPkgs system;
    in {
      neovim = pkgs.callPackage ./packages/neovim {};
      nixhashsync = nixhashsync.packages.${system}.default;

      kid-image = pkgs.nixos-install-tools.qemuImage {
        name = "nixos-vm.qcow2";
        configuration = nixosConfigurations.kid;
      };

      kid = pkgs.runCommand "run-kid" {} ''
        mkdir -p $out/bin

        # Store paths for QEMU binaries
        QEMU_IMG="${pkgs.qemu}/bin/qemu-img"
        QEMU_SYSTEM="${pkgs.qemu}/bin/qemu-system-aarch64"
        BASE_PATH=./etc/nixos/vm/main
        QCOW=$out/nixos-vm.qcow2
        SIZE=100G
        MEM=4096

        cat > $out/bin/run-kid << EOF
        #!/bin/sh
        nix build .#packages.${system}.kid-image
        sudo ln -sf ./result/nixos-vm.qcow2 $QCOW

        # Create the disk image if it doesn't exist
        ! [ -d $BASE_PATH ] && mkdir -p $BASE_PATH

        # Run QEMU with hardcoded store paths
        echo "starting qemu VM kid"
        echo "$SIZE"
        echo "$MEM"
        echo "$QCOW"
        echo "$QEMU_IMG"
        echo "$QEMU_SYSTEM"
        echo "starting qemu VM kid"
        $QEMU_SYSTEM \
          -machine virt \
          -accel hvf \
          -cpu host \
          -m $MEM \
          -smp 2 \
          -drive file=$QCOW,if=virtio \
          -netdev user,id=net0,hostfwd=tcp::2222-:22,net=192.168.50.0/24,dhcpstart=192.168.50.10 \
          -device virtio-net-pci,netdev=net0 \
          -nographic \
          -D qemu.log -d guest_errors,unimp
        EOF
        chmod +x $out/bin/run-kid
      '';
    });
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
