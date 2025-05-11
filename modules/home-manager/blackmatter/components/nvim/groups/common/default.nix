{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.common;
  common = import ../../common;
  configPath = "${common.includesPath}/common";
in {
  options.blackmatter.components.nvim.plugin.groups.common = {
    enable = mkEnableOption "plugins that should always be included";
  };
  imports = [
    ../../plugins/nvim-lua/plenary
    ../../plugins/nvim-tree/nvim-web-devicons
  ];
  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.file."${configPath}/init.lua".source = ./init.lua;
        home.file."${configPath}/notify.lua".source = ./notify.lua;
        home.file."${configPath}/settings.lua".source = ./settings.lua;
        home.file."${configPath}/autocmds.lua".source = ./autocmds.lua;
        blackmatter.components.nvim.plugins = {
          nvim-lua."plenary.nvim".enable = true;
          nvim-tree.nvim-web-devicons.enable = true;
        };
      }
    )
  ];
}
