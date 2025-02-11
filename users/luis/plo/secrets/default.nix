{ pkgs, ... }:
{
  imports = [
    ./aws.nix
    ./attic
  ];
  # sops.validateSopsFiles = false;
  sops.gnupg.home = "/home/luis/.gnupg";
  sops.gnupg.sshKeyPaths = [ ];
  programs.gpg.enable = true;
  services.gpg-agent.enable = true;
  services.gpg-agent.pinentryPackage = pkgs.pinentry-curses;
  services.gpg-agent.extraConfig = ''
    default-cache-ttl 600
    max-cache-ttl 7200
  '';
}
