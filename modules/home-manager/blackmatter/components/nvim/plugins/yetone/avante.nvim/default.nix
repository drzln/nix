{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.programs.nvim.plugins.${author}.${name};
  common = import ../../../common;
  url = "${common.baseRepoUrl}/${author}/${name}";
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  author = "yetone";
  name = "avente.nvim";
  ref = "main";
  rev = import ./rev.nix;
in {
  options.blackmatter.programs.nvim.plugins.${author}.${name}.enable =
    mkEnableOption "${author}/${name}";

  config = mkMerge [
    (mkIf cfg.enable {
      home.file."${plugPath}".source =
        builtins.fetchGit {inherit ref rev url;};
    })
  ];
}
