{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim;
in {
  imports = [./groups];
  options.blackmatter.components.nvim = {
    enable = mkEnableOption "enable neovim configuration";
    package = mkOption {
      type = types.package;
      default = pkgs.neovim;
      description = mdDoc "neovim configuration management";
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = [cfg.package];
      xdg.configFile."nvim/init.lua".source = ./conf/init.lua;
      blackmatter.components.nvim.plugin.groups.enable = true;
    })
  ];
}
