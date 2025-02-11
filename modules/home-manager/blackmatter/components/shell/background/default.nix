{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.shell.background;
in
{
  options = {
    blackmatter = {
      components = {
        shell.background.enable = mkEnableOption "shell.background";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.file."backgrounds/nord/tools".source = builtins.fetchGit {
        url = "https://github.com/arcticicestudio/nord.git";
        ref = "develop";
        rev = "c93f12b23baac69a92e7559f69e7a60c20b9da0d";
      };
      home.file."backgrounds/nord/backgrounds".source = builtins.fetchGit {
        url = "https://github.com/dxnst/nord-backgrounds.git";
        ref = "main";
        rev = "c47d6b8b0ea391fabbb79aa005703ae5549ffdc4";
      };
    })
  ];
}
