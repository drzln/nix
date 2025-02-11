{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.profiles.winter;
in
{
  imports = [
    ../../components/nvim
    ../../components/shell
    ../../components/desktop
    ../../components/gitconfig
    ../../components/kubernetes
  ];

  options = {
    blackmatter = {
      profiles = {
        winter = {
          enable = mkEnableOption "enable the winter profile";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable)
      {
        blackmatter.components.nvim.enable = true;
        blackmatter.components.shell.enable = true;
        blackmatter.components.desktop.enable = true;
      })
  ];
}
