{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.shell.tools;
in
{
  options = {
    blackmatter = {
      components = {
        shell.tools.enable = mkEnableOption "shell.tools";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      programs.jq.enable = true;
      programs.direnv.enable = true;
    })
  ];
}
