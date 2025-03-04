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
  options.blackmatter.components.nvim.plugin.groups.completion = {
    enable = mkEnableOption name;
  };

  imports = [
    ../../plugins/avante/avante.nvim
  ];

  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.file."${configPath}".source = ./config.lua;
        blackmatter.components.nvim.plugins = {
          avante."avante.nvim".enable = true;
        };
      }
    )
  ];
}
