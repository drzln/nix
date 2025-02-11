{ requirements, pkgs, ... }: {
  imports = [
    requirements.outputs.homeManagerModules.blackmatter
  ];
  blackmatter.components.nvim.enable = true;
  blackmatter.components.nvim.package = pkgs.neovim_drzln;
  blackmatter.components.shell.enable = true;
  blackmatter.components.gitconfig.enable = false;
  blackmatter.components.gitconfig.email = "gahb.dias@gmail.com";
  blackmatter.components.gitconfig.user = "gabrielad";
  blackmatter.components.desktop.enable = true;
  # blackmatter.components.desktop.monitors = {
  #   main = {
  #     name = "DP-2"; # Secondary monitor output name
  #     mode = "1920x1080"; # Resolution of the monitor
  #     rate = "360"; # Refresh rate in Hz for a higher refresh secondary monitor
  #   };
  # };
}
