{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell;
in {
  imports = [
    ./background
    ./starship
    ./packages
    ./tools
    ./zsh
    ./fzf
    ./envrc
    ./tmux
  ];

  options = {
    blackmatter = {
      components = {
        shell = {
          enable = mkEnableOption "turn on shell customizations";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # xdg.configFile."rubocop/config.yml".source = ./rubocop/config.yml;
      # home.file.".solargraph.yml".source = ./solargraph/config.yml;

      blackmatter.components.shell.background.enable = true;
      blackmatter.components.shell.packages.enable = true;
      blackmatter.components.shell.starship.enable = true;
      blackmatter.components.shell.tools.enable = true;
      blackmatter.components.shell.zsh.enable = true;
      blackmatter.components.shell.fzf.enable = true;
      blackmatter.components.shell.tmux.enable = true;
    })
  ];
}
