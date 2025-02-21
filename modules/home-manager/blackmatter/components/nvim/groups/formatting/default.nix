{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.formatting;
  common = import ../../common;
  configPath = "${common.includesPath}/formatting/config.lua";
in {
  options.blackmatter.components.nvim.plugin.groups.formatting = {
    enable = mkEnableOption "manage formatting";
  };

  imports = [
    ../../plugins/stevearc/conform.nvim
  ];

  config = mkMerge [
    (
      mkIf cfg.enable
      {
        home.packages = with pkgs; [rustfmt taplo shfmt];
        home.file."${configPath}".source = ./config.lua;
        blackmatter.components.nvim.plugins = {
          # formatting framework
          stevearc."conform.nvim".enable = true;
        };
      }
    )
  ];
}
