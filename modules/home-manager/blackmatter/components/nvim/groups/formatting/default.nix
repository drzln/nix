{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugin.groups.formatting;
in
{
  options.blackmatter.components.nvim.plugin.groups.formatting =
    {
      enable = mkEnableOption "manage formatting";
    };

  imports = [
    ../../plugins/stevearc/conform.nvim
  ];

  config =
    mkMerge [
      (mkIf cfg.enable
        {
          blackmatter.components.nvim.plugins =
            {
							# formatting framework
              stevearc."conform.nvim".enable = true;
            };
        }
      )
    ];
}
