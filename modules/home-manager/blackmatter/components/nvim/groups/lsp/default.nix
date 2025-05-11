{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.lsp;
  common = import ../../common;
  configPath = "${common.includesPath}/lsp";
in {
  options.blackmatter.components.nvim.plugin.groups.lsp = {
    enable = mkEnableOption "lsp";
  };
  imports = [
    ../../plugins/williamboman/mason-lspconfig.nvim
    ../../plugins/williamboman/mason.nvim
    ../../plugins/neovim/nvim-lspconfig
    ../../plugins/hrsh7th/cmp-nvim-lsp
    ../../plugins/hrsh7th/nvim-cmp
  ];
  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.activation.postBuildHook = lib.mkAfter ''
          rm -rf ~/.local/share/nvim/mason/bin/black
          rm -rf ~/.local/share/nvim/mason/bin/stylua
          rm -rf ~/.local/share/nvim/mason/bin/dprint
          rm -rf ~/.local/share/nvim/mason/bin/rustfmt
          rm -rf ~/.local/share/nvim/mason/bin/rust-analyzer
          rm -rf ~/.local/share/nvim/mason/bin/markdown-oxide
          rm -rf ~/.local/share/nvim/mason/bin/ruby-lsp
          rm -rf ~/.local/share/nvim/mason/bin/tree-sitter
        '';
        home.file."${configPath}/init.lua".source = ./init.lua;
        home.file."${configPath}/settings.lua".source = ./settings.lua;
        home.file."${configPath}/filetypes.lua".source = ./filetypes.lua;
        home.file."${configPath}/mason.lua".source = ./mason.lua;
        home.file."${configPath}/servers.lua".source = ./servers.lua;
        home.file."${configPath}/utils.lua".source = ./utils.lua;
        home.file."${configPath}/exclude_list.lua".source = ./exclude_list.lua;
        home.packages = with pkgs;
        with dotnetCorePackages;
        with rubyPackages_3_4;
        with luajitPackages;
        with php84Packages;
        with nodePackages; [
          go
          gcc
          zulu
          nixd
          bash
          opam
          unzip
          cmake
          black
          ninja
          nodejs
          prettier
          composer
          solargraph
          tree-sitter
          luarocks-nix
          swift-format
          rust-analyzer
          markdown-oxide
          sourcekit-lsp
          google-java-format

          (python312.withPackages (ps: with ps; [pip]))
        ];
        blackmatter.components.nvim.plugins = {
          hrsh7th.nvim-cmp.enable = true;
          hrsh7th.cmp-nvim-lsp.enable = true;
          neovim.nvim-lspconfig.enable = true;
          williamboman."mason.nvim".enable = true;
          williamboman."mason-lspconfig.nvim".enable = true;
        };
      }
    )
  ];
}
