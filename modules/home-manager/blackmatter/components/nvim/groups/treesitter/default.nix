{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugin.groups.treesitter;
in
{
  options.blackmatter.components.nvim.plugin.groups.treesitter =
    {
      enable = mkEnableOption "treesitter";
    };

  imports = [
    ../../plugins/nvim-treesitter/nvim-treesitter
    # ../../plugins/nvim-treesitter/playground
    # ../../plugins/nvim-treesitter/nvim-treesitter-context
    # ../../plugins/nvim-treesitter/nvim-treesitter-refactor
    # ../../plugins/nvim-treesitter/nvim-treesitter-textobjects
    # ../../plugins/windwp/nvim-ts-autotag
    # ../../plugins/p00f/nvim-ts-rainbow
    # ../../plugins/RRethy/nvim-treesitter-endwise
    # ../../plugins/RRethy/nvim-treesitter-textsubjects
    # ../../plugins/JoosepAlviste/nvim-ts-context-commentstring
  ];

  config =
    mkMerge [
      (mkIf cfg.enable
        {
          blackmatter.components.nvim.plugins =
            {
              nvim-treesitter.nvim-treesitter.enable = true;
              # nvim-treesitter.playground.enable = true;
              # nvim-treesitter.nvim-treesitter-context.enable = false;
              # nvim-treesitter.nvim-treesitter-refactor.enable = true;
              # nvim-treesitter.nvim-treesitter-textobjects.enable = false;
              # windwp.nvim-ts-autotag.enable = false;
              # now a part of nvim-treesitter as config
              # p00f.nvim-ts-rainbow.enable = false;
              # RRethy.nvim-treesitter-endwise.enable = true;
              # RRethy.nvim-treesitter-textsubjects.enable = true;
              # also merged into native nvim-treesitter so disabled now
              # JoosepAlviste.nvim-ts-context-commentstring.enable = false;
            };
        }
      )
    ];
}
