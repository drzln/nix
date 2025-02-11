{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugin.groups.tmux;
in
{
  options.blackmatter.components.nvim.plugin.groups.tmux =
    {
      enable = mkEnableOption "tmux";
    };

  imports = [
    ../../plugins/christoomey/vim-tmux-navigator
  ];

  config =
    mkMerge [
      (mkIf cfg.enable
        {
          blackmatter.components.nvim.plugins =
            {
              christoomey.vim-tmux-navigator.enable = true;
            };
        }
      )
    ];
}
