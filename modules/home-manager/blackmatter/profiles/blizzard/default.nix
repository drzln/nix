# modules/home-manager/blackmatter/profiles/blizzard/default.nix
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.profiles.blizzard;
in {
  imports = [
    ../../components/desktop
    ../../components/shell
    ../../components/nvim
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
        blackmatter.components.desktop.hyprland.enable = cfg.enable;
        blackmatter.components.desktop.enable = cfg.enable;
        blackmatter.components.shell.enable = cfg.enable;
        blackmatter.components.nvim.enable = cfg.enable;
      })
  ];
}
