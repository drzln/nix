{
  config,
  lib,
  ...
}:
with lib; let
  name = "completion";
  plugName = name;
  cfg = config.blackmatter.components.nvim.plugin.groups.${name};
  common = import ../../common;
  configPath = "${common.includesPath}/${plugName}/init.lua";
in {
  options.blackmatter.components.nvim.plugin.groups.completion = {
    enable = mkEnableOption name;
  };

  imports = [
    ../../plugins/hrsh7th/nvim-cmp
    ../../plugins/hrsh7th/cmp-path
    ../../plugins/sar/cmp-lsp.nvim
    ../../plugins/L3MON4D3/LuaSnip
    ../../plugins/hrsh7th/cmp-buffer
    ../../plugins/yetone/avante.nvim
    ../../plugins/hrsh7th/cmp-cmdline
    ../../plugins/ray-x/cmp-treesitter
    ../../plugins/hrsh7th/cmp-nvim-lsp
    ../../plugins/onsails/lspkind.nvim
    ../../plugins/zbirenbaum/copilot-cmp
    ../../plugins/zbirenbaum/copilot.lua
    ../../plugins/rafamadriz/friendly-snippets
    ../../plugins/muni/nui.nvim
  ];

  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.file."${configPath}".source = ./init.lua;
        blackmatter.components.nvim.plugins = {
          L3MON4D3.LuaSnip.enable = true;
          hrsh7th.cmp-path.enable = true;
          hrsh7th.nvim-cmp.enable = true;
          hrsh7th.cmp-buffer.enable = true;
          sar."cmp-lsp.nvim".enable = true;
          hrsh7th.cmp-cmdline.enable = true;
          yetone."avante.nvim".enable = false;
          hrsh7th.cmp-nvim-lsp.enable = true;
          ray-x.cmp-treesitter.enable = true;
          onsails."lspkind.nvim".enable = true;
          zbirenbaum."copilot.lua".enable = true;
          zbirenbaum."copilot-cmp".enable = true;
          rafamadriz.friendly-snippets.enable = true;
          muni."nui.nvim".enable = true;
        };
      }
    )
  ];
}
