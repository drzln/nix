{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.desktop.kitty;
in
{
  options = {
    blackmatter = {
      components = {
        desktop = {
          kitty = {
            enable = mkEnableOption "Manage a kitty installation";
            configFile = mkOption {
              type = types.path;
              default = ./kitty.conf; # Default to the current path
              description = "Path to the kitty configuration file";
            };
          };
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.kitty.enable = true;
      xdg.configFile."kitty/kitty.conf".source = cfg.configFile;
    })
  ];
}
