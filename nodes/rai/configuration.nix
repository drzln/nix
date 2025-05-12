# nodes/rai/configuration.nix
{inputs, ...}: let
in {
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowImportFromDerivation = true;
  imports = [
    inputs.self.nixosModules.blackmatter
    inputs.nix-kubernetes.nixosModules.kubernetes
    ./base-configuration.nix
    ./base-hardware.nix
  ];
}
