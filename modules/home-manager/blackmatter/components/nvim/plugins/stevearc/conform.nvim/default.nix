{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugins.${author}.${name};
  common = import ../../../common;
  url = "${common.baseRepoUrl}/${author}/${name}";
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  author = "stevearc";
  name = "conform.nvim";
  ref = "master";
  rev = import ./rev.nix;
in {
  options.blackmatter.components.nvim.plugins.${author}.${name}.enable =
    mkEnableOption "${author}/${name}";

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        stylua
        alejandra
      ];
      home.file."${plugPath}".source = builtins.fetchGit {inherit ref rev url;};
    })
  ];
}
