{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugins.${author}.${name};
  common = import ../../../common;
  url = "${common.baseRepoUrl}/${author}/${name}";
  author = "nvim-treesitter";
  name = "nvim-treesitter-context";
  plugName = name;
  ref = "master";
  rev = import ./rev.nix;
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  configPath = "${common.includesPath}/${author}/${plugName}.lua";
in
{
  options.blackmatter.components.nvim.plugins.${author}.${name}.enable =
    mkEnableOption "${author}/${name}";

  config = mkMerge [
    (mkIf cfg.enable {
      home.file."${plugPath}".source =
        builtins.fetchGit { inherit ref rev url; };
    })
  ];
}
