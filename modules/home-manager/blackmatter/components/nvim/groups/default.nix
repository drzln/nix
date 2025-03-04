{
  lib,
  config,
  ...
}: let
  cfg = config.blackmatter.components.nvim.plugin.groups;
in
  with lib; {
    imports = [
      ./common
      ./treesitter
      ./theming
      ./formatting
      ./keybindings
      ./lsp
      ./completion
      ./ai
      # ./languages
      # ./debugging
      # ./tmux
    ];

    options = {
      blackmatter = {
        components = {
          nvim = {
            plugin = {
              groups = {
                enable = mkEnableOption "nvim.groups";
              };
            };
          };
        };
      };
    };

    config = mkMerge [
      (mkIf cfg.enable {
        blackmatter.components.nvim.plugin.groups.common.enable = true;
        blackmatter.components.nvim.plugin.groups.treesitter.enable = true;
        blackmatter.components.nvim.plugin.groups.theming.enable = true;
        blackmatter.components.nvim.plugin.groups.formatting.enable = true;
        blackmatter.components.nvim.plugin.groups.keybindings.enable = true;
        blackmatter.components.nvim.plugin.groups.lsp.enable = true;
        blackmatter.components.nvim.plugin.groups.completion.enable = true;
        blackmatter.components.nvim.plugin.groups.ai.enable = true;
        # blackmatter.components.nvim.plugin.groups.telescope.enable = true;
        # blackmatter.components.nvim.plugin.groups.languages.enable = true;
        # blackmatter.components.nvim.plugin.groups.debugging.enable = true;
        # blackmatter.components.nvim.plugin.groups.tmux.enable = true;
      })
    ];
  }
