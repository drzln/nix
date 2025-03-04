{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.nvim.plugins.muni.${name};
  common = import ../../../common;
  url = "${common.baseRepoUrl}/${author}/${name}";
  plugPath = "${common.basePlugPath}/${author}/start/${name}";
  author = "MunifTanjim";
  name = "nui.nvim";
  ref = "main";
  rev = import ./rev.nix;
in {
  options.blackmatter.components.nvim.plugins.muni.${name}.enable =
    mkEnableOption "${author}/${name}";

  config = mkMerge [
    (mkIf cfg.enable {
      home.file."${plugPath}".source =
        builtins.fetchGit {inherit ref rev url;};
    })
  ];
}
