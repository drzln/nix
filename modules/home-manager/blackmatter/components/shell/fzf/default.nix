{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.shell.fzf;
in
{
  options = {
    blackmatter = {
      components = {
        shell.fzf.enable = mkEnableOption "shell.fzf";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      programs.fzf.enable = true;
      programs.fzf.enableZshIntegration = true;
    })
  ];
}
