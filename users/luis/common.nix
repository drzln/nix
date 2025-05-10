# users/luis/common.nix
{...}: {
  home.username = "luis";
  home.homeDirectory = "/home/luis";
  programs.ssh.enable = true;
  programs.ssh.userKnownHostsFile = "/dev/null";
  programs.ssh.extraConfig = ''
    StrictHostKeyChecking no
    SetEnv TERM=xterm-256color
  '';
}
