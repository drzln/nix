{pkgs, ...}: {
  # Essential system configuration
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Add users, services, packages, etc.
  users.users.root.password = "nixos"; # Example (change this!)
  environment.systemPackages = [pkgs.curl pkgs.vim];

  system.stateVersion = "23.11";
}
