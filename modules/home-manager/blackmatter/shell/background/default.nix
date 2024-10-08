{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter;
in
{
  options = {
    blackmatter = {
      shell.background.enable = mkEnableOption "shell.background";
    };
  };

  config = mkMerge [
    (mkIf cfg.shell.background.enable {
      home.file."backgrounds/nord/tools".source = builtins.fetchGit {
        url = "ssh://git@github.com/arcticicestudio/nord";
        ref = "develop";
        rev = "c93f12b23baac69a92e7559f69e7a60c20b9da0d";
      };
      home.file."backgrounds/nord/backgrounds".source = builtins.fetchGit {
        url = "git@github.com:dxnst/nord-backgrounds.git";
        ref = "main";
        rev = "c47d6b8b0ea391fabbb79aa005703ae5549ffdc4";
      };
    })
  ];
}
