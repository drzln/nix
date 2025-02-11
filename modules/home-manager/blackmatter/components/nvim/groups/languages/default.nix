{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugin.groups.languages;
in
{
  options.blackmatter.components.nvim.plugin.groups.languages =
    {
      enable = mkEnableOption "languages";
    };

  imports = [
    ../../plugins/hashivim/vim-terraform
  ];

  config =
    mkMerge [
      (mkIf cfg.enable
        {
          blackmatter.components.nvim.plugins =
            {
              hashivim."vim-terraform".enable = false;
            };
        }
      )
    ];
}
