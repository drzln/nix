{ lib, config, outputs, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugins.${author}.${name};
  common = import ../../../common;
  url = "${common.baseRepoUrl}/${author}/${name}";
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  configPath = "${common.includesPath}/${author}/${plugName}.lua";
	plugName = name;
  author = "nvim-treesitter";
  name = "nvim-treesitter";
  ref = "master";
  rev = import ./rev.nix;
in
{
  options = {
    blackmatter = {
      components = {
        nvim = {
          plugins = {
            nvim-treesitter = {
              nvim-treesitter = {
                enable = mkEnableOption "${author}/${name}";
              };
            };
          };
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.file."${plugPath}".source =
        builtins.fetchGit { inherit ref rev url; };

      home.file."${configPath}".source = ./config.lua;
    })
  ];
}
