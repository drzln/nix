# modules/home-manager/blackmatter/components/nvim/groups/theming/default.nix
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.theming;
  common = import ../../common;
  configPath = "${common.includesPath}/theming/init.lua";
in {
  options.blackmatter.components.nvim.plugin.groups.theming = {
    enable = mkEnableOption "theming";
  };
  imports = [
    ../../plugins/shaunsingh/nord.nvim
    ../../plugins/nvim-lualine/lualine.nvim
    ../../plugins/norcalli/nvim-colorizer.lua
    ../../plugins/akinsho/bufferline.nvim
  ];
  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.file."${configPath}".source = ./init.lua;
        blackmatter.components.nvim.plugins = {
          norcalli."nvim-colorizer.lua".enable = true;
          nvim-lualine."lualine.nvim".enable = true;
          akinsho."bufferline.nvim".enable = true;
          shaunsingh."nord.nvim".enable = true;
        };
      }
    )
  ];
}
