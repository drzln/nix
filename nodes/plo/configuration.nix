# nodes/plo/configuration.nix
{
  pkgs,
  requirements,
  ...
}: let
  sudo-users-common = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "libvirtd"
      "docker"
      "podman"
      "wheel"
      "audio"
      "video"
    ];
    packages = with pkgs; [
      home-manager
      element-desktop
    ];
  };
in {
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowImportFromDerivation = true;
  imports = [
    requirements.inputs.self.nixosModules.blackmatter
    requirements.inputs.nix-kubernetes.nixosModules.kubernetes
    ./kubernetes
    ./secrets.nix
  ];
  blackmatter.profiles.blizzard.enable = true;
  # makes /bin/bash work
  services.envfs.enable = true;
  environment.systemPackages = with pkgs; [
    kubectl
    runc
  ];
  users.users.luis =
    {
      uid = 1001;
      description = "luis";
    }
    // sudo-users-common;
  security.sudo.extraConfig = ''
    luis ALL=(ALL) NOPASSWD:ALL
  '';
}
