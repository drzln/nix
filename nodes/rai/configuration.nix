# nodes/rai/configuration.nix
{
  inputs,
  pkgs,
  ...
}: let
in {
  environment.systemPackages = with pkgs; [ghostty.terminfo];
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowImportFromDerivation = true;
  imports = [
    inputs.nix-kubernetes.nixosModules.kubernetes
    inputs.self.nixosModules.blackmatter
    ./base-configuration.nix
    ./base-hardware.nix
    ../common/kubernetes
  ];
}
