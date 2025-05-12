{pkgs, ...}: {
  networking.hostName = "rai";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  environment.systemPackages = with pkgs; [
    wget
    vim
  ];
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = true;
  networking.firewall.enable = false;
}
