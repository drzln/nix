{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugins.${author}.${name};
  common = import ../../../common;
  url = "${common.baseRepoUrl}/${author}/${name}";
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  configPath = "${common.includesPath}/${author}/${plugName}.lua";
  author = "jose-elias-alvarez";
  name = "null-ls.nvim";
  plugName = "null-ls";
  ref = "main";
  rev = import ./rev.nix;
in
{
  options.blackmatter.components.nvim.plugins.${author}.${name}.enable =
    mkEnableOption "${author}/${name}";

  config = mkMerge [
    (mkIf cfg.enable {
      # install some dependencies for null-ls for our config
      home.packages = with pkgs; [
        nodePackages.prettier
        # terraform
      ];
      # handles some linting and formatting
      home.file."${plugPath}".source =
        builtins.fetchGit { inherit ref rev url; };

      home.file."${configPath}".source = ./config.lua;
    })
  ];
}
