{
  config,
  lib,
  pkgs,
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
    # ../../plugins/ray-x/lsp_signature.nvim
    # ../../plugins/onsails/lspkind.nvim
  ];

  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.activation.postBuildHook = lib.mkAfter ''
          rm -rf ~/.local/share/nvim/mason/bin/stylua
        '';
        home.file."${configPath}".source = ./config.lua;
        home.packages = with pkgs;
        with php84Packages;
        with nodePackages; [
          go
          bash
          opam
          unzip
          black
          nodejs
          zulu23
          prettier
          composer
          ruby_3_4
          solargraph
          cmake
          python314
          luajitPackages.luarocks-nix
          dotnetCorePackages.dotnet_9.sdk
          dotnetCorePackages.dotnet_9.runtime
        ];
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
