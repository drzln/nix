{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.programs.nvim.plugins.${author}.${name};
  common = import ../../../common;
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  configPath = "${common.includesPath}/${author}/${plugName}.lua";
  author = "ojroques";
  name = "nvim-lspfuzzy";
  url = "https://github.com/${author}/${name}";
  ref = "main";
  rev = import ./rev.nix;
in
{
  options.blackmatter.programs.nvim.plugins.${author}.${name}.enable =
    mkEnableOption "${author}/${name}";

  config = mkMerge [
    (mkIf cfg.enable {
      home.file."${plugPath}".source =
        builtins.fetchGit { inherit ref rev url; };
    })
  ];
}
