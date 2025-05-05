{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.common;
  common = import ../../common;
  configPath = "${common.includesPath}/common/config.lua";
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
        home.file."${configPath}".source = ./config.lua;
        blackmatter.components.nvim.plugins = {
          nvim-lua."plenary.nvim".enable = true;
          nvim-tree.nvim-web-devicons.enable = true;
        };
      }
    )
  ];
}
