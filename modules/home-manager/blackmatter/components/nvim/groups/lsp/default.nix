{
  lib,
  pkgs,
  config,
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
        home.file."${configPath}".source = ./config.lua;
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
          (python312.withPackages (ps: with ps; [pip]))
          solargraph
          luarocks-nix
          google-java-format
          # dotnet_9.sdk
          # dotnet_9.runtime
          swift-format
          rust-analyzer
          markdown-oxide
          sourcekit-lsp
          tree-sitter
          # (pkgs.ruby_3_4.withPackages (ps: with ps; [ruby-lsp]))
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
