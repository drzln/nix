{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.desktop;
in
{
  imports = [
    ./alacritty
    ./chrome
    ./firefox
    ./i3
    ./kitty
    ./packages
  ];

  options = {
    blackmatter = {
      components = {
        desktop = {
          enable = mkEnableOption "enable the desktop";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      blackmatter.components.desktop.alacritty.enable = true;
      blackmatter.components.desktop.chrome.enable = false;
      blackmatter.components.desktop.firefox.enable = false;
      blackmatter.components.desktop.i3.enable = true;
      blackmatter.components.desktop.kitty.enable = true;
      blackmatter.components.desktop.packages.enable = true;
    })
  ];
}
