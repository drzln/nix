# Edit this configuration file to define what should be installed on                                                                # your system. Help is available in the configuration.nix(5) man page, on
{pkgs, ...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "rai";
  environment.systemPackages = with pkgs; [
    wget
    vim
  ];
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = true;
  networking.firewall.enable = false;
}
