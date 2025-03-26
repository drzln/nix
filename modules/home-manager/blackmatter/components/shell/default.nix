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
    ./envrc
    ./tmux
    ./zsh
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
      blackmatter.components.shell.zsh.enable = true;
      blackmatter.components.shell.background.enable = true;
      blackmatter.components.shell.packages.enable = true;
      blackmatter.components.shell.starship.enable = true;
      blackmatter.components.shell.tools.enable = true;
      blackmatter.components.shell.tmux.enable = false;
    })
  ];
}
