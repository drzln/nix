{ lib, config, ... }:
with lib;
let
  author = "nanotee";
  name = "nvim-lsp-basics";
  url = "https://github.com/${author}/${name}";
  ref = "main";
  rev = import ./rev.nix;
  plugPath = ".local/share/nvim/site/pack/${author}/start/${name}";
  cfg = config.blackmatter.programs.nvim.plugins.${author}.${name};
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
