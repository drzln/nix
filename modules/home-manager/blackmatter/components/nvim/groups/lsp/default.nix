{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.lsp;
  common = import ../../common;
  configPath = "${common.includesPath}/lsp/config.lua";
in {
  options.blackmatter.components.nvim.plugin.groups.lsp = {
    enable = mkEnableOption "lsp";
  };

  imports = [
    ../../plugins/neovim/nvim-lspconfig
    ../../plugins/williamboman/mason.nvim
    ../../plugins/williamboman/mason-lspconfig.nvim
    ../../plugins/hrsh7th/cmp-nvim-lsp
    ../../plugins/hrsh7th/nvim-cmp
    # ../../plugins/ray-x/lsp_signature.nvim
    # ../../plugins/onsails/lspkind.nvim
  ];

  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.file."${configPath}".source = ./config.lua;
        blackmatter.components.nvim.plugins = {
          neovim.nvim-lspconfig.enable = true;
          williamboman."mason.nvim".enable = true;
          williamboman."mason-lspconfig.nvim".enable = true;
          hrsh7th.cmp-nvim-lsp.enable = true;
          hrsh7th.nvim-cmp.enable = true;
          # ray-x."lsp_signature.nvim".enable = true;
          # onsails."lspkind.nvim".enable = true;
        };
      }
    )
  ];
}
