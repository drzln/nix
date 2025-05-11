# modules/home-manager/blackmatter/components/nvim/groups/default.nix
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
      ./keybindings
      ./completion
      ./treesitter
      ./formatting
      ./theming
      ./lsp
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
        blackmatter.components.nvim.plugin.groups.keybindings.enable = true;
        blackmatter.components.nvim.plugin.groups.completion.enable = true;
        blackmatter.components.nvim.plugin.groups.treesitter.enable = true;
        blackmatter.components.nvim.plugin.groups.formatting.enable = true;
        blackmatter.components.nvim.plugin.groups.theming.enable = true;
        blackmatter.components.nvim.plugin.groups.lsp.enable = true;
      })
    ];
  }
