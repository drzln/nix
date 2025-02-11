{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugin.groups.telescope;
in
{
  options.blackmatter.components.nvim.plugin.groups.telescope =
    {
      enable = mkEnableOption "telescope";
    };

  imports = [
    ../../plugins/nvim-telescope/telescope.nvim
    ../../plugins/nvim-telescope/telescope-file-browser.nvim
    ../../plugins/nvim-telescope/telescope-project.nvim
    ../../plugins/nvim-telescope/telescope-dap.nvim
    ../../plugins/nvim-telescope/telescope-z.nvim
    ../../plugins/danielpieper/telescope-tmuxinator.nvim
  ];

  config =
    mkMerge [
      (mkIf cfg.enable
        {
          blackmatter.components.nvim.plugins =
            {
              nvim-telescope."telescope.nvim".enable = true;
              nvim-telescope."telescope-file-browser.nvim".enable = false;
              nvim-telescope."telescope-project.nvim".enable = false;
              nvim-telescope."telescope-dap.nvim".enable = false;
              nvim-telescope."telescope-z.nvim".enable = false;
              # TODO: off due to sandbox error
              danielpieper."telescope-tmuxinator.nvim".enable = false;
            };
        }
      )
    ];
}
