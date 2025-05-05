# users/luis/plo/secrets/default.nix
{pkgs, ...}: {
  imports = [
    ./aws.nix
    ./openai.nix
    ./attic
  ];
  # sops.validateSopsFiles = false;
  sops.gnupg.home = "/home/luis/.gnupg";
  sops.gnupg.sshKeyPaths = [];
  programs.gpg.enable = true;
  services.gpg-agent.enable = true;
  services.gpg-agent.pinentry.package = pkgs.pinentry-curses;
  services.gpg-agent.extraConfig = ''
    default-cache-ttl 600
    max-cache-ttl 7200
  '';
}
