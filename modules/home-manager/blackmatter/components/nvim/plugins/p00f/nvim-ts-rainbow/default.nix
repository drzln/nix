{ lib, config, ... }:
with lib;
let
  author = "p00f";
  name = "nvim-ts-rainbow";
  url = "https://github.com/${author}/${name}";
  ref = "master";
  rev = import ./rev.nix;
  plugPath = ".local/share/nvim/site/pack/${author}/start/${name}";
  cfg = config.blackmatter.components.nvim.plugins.${author}.${name};
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
