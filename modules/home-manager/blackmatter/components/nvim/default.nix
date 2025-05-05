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
      # include the neovim package
      home.packages = [cfg.package];

      # load a minimal set of utilities so you can play legos
      xdg.configFile."nvim/init.lua".source = ./conf/init.lua;
      xdg.configFile."nvim/lua/utils".source = ./conf/lua/utils;

      # all other behaviors controlled by groups
      blackmatter.components.nvim.plugin.groups.enable = true;
    })
  ];
}
