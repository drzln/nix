{
  pkgs,
  nixpkgs,
  ...
}: {
  imports = [
    # Essential for QEMU VMs
    # <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
    "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ];

  time.timeZone = "America/New_York";
  networking.firewall.allowedTCPPorts = [22 2222];
  networking.firewall.enable = false;

  # Basic system settings
  boot.loader.grub.device = "nodev"; # Direct kernel boot with QEMU
  networking.useDHCP = true;

  users.users.ldesiqueira = {
    uid = 1002;
    isNormalUser = true;
    extraGroups = ["wheel"]; # Allow sudo
    password = "letmein";
    shell = pkgs.zsh;
  };

  # OpenSSH for remote access
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = true;
  services.openssh.extraConfig = ''
    LogLevel DEBUG3
    AllowTcpForwarding yes
    GatewayPorts yes
  '';
  systemd.services.sshd.serviceConfig.StandardOutput = "journal+console";
  systemd.services.sshd.serviceConfig.StandardError = "journal+console";

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
