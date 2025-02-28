{pkgs, ...}: {
  imports = [
    # Essential for QEMU VMs
    <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
  ];

  # Basic system settings
  boot.loader.grub.device = "nodev"; # Direct kernel boot with QEMU
  networking.useDHCP = true;
  time.timeZone = "America/New_York";

  # User configuration
  users.users.vmuser = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Allow sudo
    password = "password123";
  };

  # OpenSSH for remote access
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = true;

  # Networking
  networking.interfaces.eth0.useDHCP = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    vim # Text editor
    git # Version control
    htop # System monitoring
    curl # Network tool
  ];

  # Enable QEMU guest services
  virtualisation.qemuGuest.enable = true;

  # Default target
  systemd.services.default.target = "multi-user.target";
}
