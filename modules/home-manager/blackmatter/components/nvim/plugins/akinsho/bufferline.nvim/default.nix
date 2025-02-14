{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugins.${author}.${name};
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  url = "${common.baseRepoUrl}/${author}/${name}";
  common = import ../../../common;
  name = "bufferline.nvim";
  rev = import ./rev.nix;
  author = "akinsho";
  ref = "main";
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
