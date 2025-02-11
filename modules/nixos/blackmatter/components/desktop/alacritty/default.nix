{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.desktop.alacritty;
in
{
  options = {
    blackmatter = {
      components.desktop.alacritty.enable = mkEnableOption "desktop.alacritty";
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      programs.alacritty.enable = true;
      xdg.configFile."alacritty/alacritty.toml".source = ./alacritty.toml;
      xdg.configFile."alacritty/alacritty.yml".source = ./alacritty.yml;
    })
  ];
}
