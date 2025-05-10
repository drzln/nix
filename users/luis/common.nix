# users/luis/common.nix
{inputs, ...}: {
  imports = [
    inputs.self.homeManagerModules.blackmatter
  ];
  home.username = "luis";
  home.homeDirectory = "/home/luis";
  programs.ssh.enable = true;
  programs.ssh.userKnownHostsFile = "/dev/null";
  programs.ssh.extraConfig = ''
    StrictHostKeyChecking no
    SetEnv TERM=xterm-256color
  '';
  blackmatter.components.gitconfig.enable = true;
  blackmatter.components.gitconfig.email = "drzzln@protonmail.com";
  blackmatter.components.gitconfig.user = "drzln";
}
