# users/luis/plo/home.nix
{...}: {
  imports = [
    ../../common.nix
    ./blackmatter.nix
    ./packages.nix
    ./secrets
  ];
  home.username = "luis";
  home.homeDirectory = "/home/luis";
  programs.ssh.enable = true;
  programs.ssh.userKnownHostsFile = "/dev/null";
  # StrictHostKeyChecking no - for changing virtual machines
  # SetEnv TERM=xterm-256color - helps ghostty when sshing
  programs.ssh.extraConfig = ''
    StrictHostKeyChecking no
    SetEnv TERM=xterm-256color
  '';
}
