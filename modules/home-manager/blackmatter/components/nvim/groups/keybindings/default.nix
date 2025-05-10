{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.keybindings;
  common = import ../../common;
  configPath = "${common.includesPath}/keybindings/init.lua";
in {
  options.blackmatter.components.nvim.plugin.groups.keybindings = {
    enable = mkEnableOption "keybindings";
  };

  imports = [
    ../../plugins/hrsh7th/nvim-cmp
  ];
  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.file."${configPath}".source = ./init.lua;
        blackmatter.components.nvim.plugins = {
          hrsh7th.nvim-cmp.enable = true;
        };
      }
    )
  ];
}
