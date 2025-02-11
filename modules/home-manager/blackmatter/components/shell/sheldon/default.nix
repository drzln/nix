{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter;
in
{
  options = {
    blackmatter = {
      shell.sheldon.enable = mkEnableOption "shell.sheldon";
    };
  };

  config = mkMerge [
    (mkIf cfg.shell.sheldon.enable {
      home.file.".config/sheldon/plugins.toml".source = ./plugins.toml;
    })
  ];
}
