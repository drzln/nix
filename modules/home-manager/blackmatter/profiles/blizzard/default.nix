{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.profiles.blizzard;
in
{
  imports = [
    ../../components/nvim
    ../../components/shell
    ../../components/desktop
  ];

  options = {
    blackmatter = {
      profiles = {
        blizzard = {
          enable = mkEnableOption "enable the blizzard profile";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable)
      {
        blackmatter.components.nvim.enable = cfg.enable;
        #blackmatter.components.nvim.package = pkgs.neovim_drzln;
        blackmatter.components.shell.enable = cfg.enable;
        blackmatter.components.desktop.enable = cfg.enable;
        blackmatter.components.desktop.hyprland.enable = cfg.enable;
      })
  ];
}
