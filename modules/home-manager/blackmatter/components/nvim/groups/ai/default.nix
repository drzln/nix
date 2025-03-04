{
  config,
  lib,
  ...
}:
with lib; let
  name = "ai";
  plugName = name;
  cfg = config.blackmatter.components.nvim.plugin.groups.${name};
  common = import ../../common;
  configPath = "${common.includesPath}/groups/${plugName}.lua";
in {
  options.blackmatter.components.nvim.plugin.groups.ai = {
    enable = mkEnableOption name;
  };

  imports = [
    ../../plugins/yetone/avante.nvim
    ../../plugins/MunifTanjim/nui.nvim
  ];

  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.file."${configPath}".source = ./config.lua;
        blackmatter.components.nvim.plugins = {
          yetone."avante.nvim".enable = true;
          # MunifTanjim."nui.nvim".enable = true;
        };
      }
    )
  ];
}
