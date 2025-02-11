{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.profiles.frost;
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
        frost = {
          enable = mkEnableOption "enable the frost profile";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable)
      {
        blackmatter.components.nvim.enable = true;
        blackmatter.components.shell.enable = true;

        # blackmatter.components.desktop.enable = true;
        blackmatter.components.desktop.kitty.enable = true;
      })
  ];
}
