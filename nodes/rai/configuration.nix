# nodes/rai/configuration.nix
{
  inputs,
  # pkgs,
  ...
}: let
  # sudo-users-common = {
  #   shell = pkgs.zsh;
  #   isNormalUser = true;
  #   extraGroups = [
  #     "networkmanager"
  #     "libvirtd"
  #     "docker"
  #     "podman"
  #     "wheel"
  #     "audio"
  #     "video"
  #   ];
  #   packages = with pkgs; [
  #     home-manager
  #   ];
  # };
in {
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowImportFromDerivation = true;
  imports = [
    inputs.self.nixosModules.blackmatter
    inputs.nix-kubernetes.nixosModules.kubernetes
    ./base-configuration.nix
    ./base-hardware.nix
    # ./kubernetes
    # ./secrets.nix
  ];
  # blackmatter.profiles.blizzard.enable = true;
  # makes /bin/bash work
  # services.envfs.enable = true;
  # environment.systemPackages = with pkgs; [
  #   kubectl
  #   runc
  # ];
  # users.users.luis =
  #   {
  #     uid = 1001;
  #     description = "luis";
  #   }
  #   // sudo-users-common;
  # security.sudo.extraConfig = ''
  #   luis ALL=(ALL) NOPASSWD:ALL
  # '';
}
