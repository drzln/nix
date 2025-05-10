{
  pkgs,
  nixpkgs,
  ...
}: {
  imports = ["${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"];
  time.timeZone = "America/New_York";
  networking.firewall.allowedTCPPorts = [22 2222];
  networking.firewall.enable = false;
  boot.loader.grub.device = "nodev"; # Direct kernel boot with QEMU
  networking.useDHCP = true;
  users.users.ldesiqueira = {
    uid = 1002;
    isNormalUser = true;
    extraGroups = ["wheel"]; # Allow sudo
    password = "letmein";
    shell = pkgs.zsh;
  };
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
  networking.interfaces.eth0.useDHCP = true;
  environment.systemPackages = with pkgs; [
    htop
    curl
    vim
    git
  ];
  virtualisation.qemu.guestAgent.enable = true;
  services.qemuGuest.enable = true;
  systemd.services.default.target = "multi-user.target";
}
