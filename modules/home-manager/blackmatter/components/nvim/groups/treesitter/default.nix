{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.treesitter;
  common = import ../../common;
  configPath = "${common.includesPath}/treesitter/config.lua";
in {
  options.blackmatter.components.nvim.plugin.groups.treesitter = {
    enable = mkEnableOption "treesitter";
  };

  imports = [
    ../../plugins/nvim-treesitter/nvim-treesitter
    ../../plugins/JoosepAlviste/nvim-ts-context-commentstring
    # ../../plugins/nvim-treesitter/playground
    # ../../plugins/nvim-treesitter/nvim-treesitter-context
    # ../../plugins/nvim-treesitter/nvim-treesitter-refactor
    # ../../plugins/nvim-treesitter/nvim-treesitter-textobjects
    # ../../plugins/windwp/nvim-ts-autotag
    # ../../plugins/p00f/nvim-ts-rainbow
    # ../../plugins/RRethy/nvim-treesitter-endwise
    # ../../plugins/RRethy/nvim-treesitter-textsubjects
  ];

  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.file."${configPath}".source = ./config.lua;
        blackmatter.components.nvim.plugins = {
          nvim-treesitter.nvim-treesitter.enable = true;
          JoosepAlviste.nvim-ts-context-commentstring.enable = true;
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
        };
      }
    )
  ];
}
