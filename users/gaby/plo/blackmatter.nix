{ requirements, pkgs, ... }: {
  imports = [
    requirements.outputs.homeManagerModules.blackmatter
  ];
  blackmatter.programs.nvim.enable = true;
  blackmatter.programs.nvim.package = pkgs.neovim_drzln;
  blackmatter.shell.enable = true;
  blackmatter.gitconfig.enable = true;
  blackmatter.gitconfig.email = "gab@pleme.io";
  blackmatter.gitconfig.user = "gaby";
  blackmatter.desktop.enable = true;
  blackmatter.desktop.monitors = {
    main = {
      name = "DP-2";      # Secondary monitor output name
      mode = "1920x1080"; # Resolution of the monitor
      rate = "360";       # Refresh rate in Hz for a higher refresh secondary monitor
    };
  };
}
