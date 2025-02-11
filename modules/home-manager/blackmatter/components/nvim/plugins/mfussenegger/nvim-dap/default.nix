{ lib, config, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugins.mfussenegger."nvim-dap";
in
{
  options.blackmatter.components.nvim.plugins.mfussenegger."nvim-dap".enable =
    mkEnableOption "mfussenegger/nvim-dap";

  config = mkMerge [
    (mkIf cfg.enable {
      home.file.".local/share/nvim/site/pack/mfussenegger/start/nvim-dap".source =
        builtins.fetchGit {
          url = "https://github.com/mfussenegger/nvim-dap";
          ref = "master";
          rev = import ./rev.nix;
        };
    })
  ];
}
