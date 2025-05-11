{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugin.groups.formatting;
  common = import ../../common;
  configPath = "${common.includesPath}/formatting";
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
        home.packages = with pkgs; [rustfmt taplo shfmt php83Packages.php-cs-fixer];
        home.file."${configPath}/init.lua".source = ./init.lua;
        blackmatter.components.nvim.plugins = {
          stevearc."conform.nvim".enable = true;
        };
      }
    )
  ];
}
