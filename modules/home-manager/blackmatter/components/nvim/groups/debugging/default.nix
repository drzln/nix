{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.nvim.plugin.groups.debugging;
in
{
  options.blackmatter.components.nvim.plugin.groups.debugging =
    {
      enable = mkEnableOption "debugging";
    };

  imports = [
    ../../plugins/ravenxrz/DAPInstall.nvim
    ../../plugins/yriveiro/dap-go.nvim
    ../../plugins/nvim-telescope/telescope-dap.nvim
    ../../plugins/Pocco81/dap-buddy.nvim
    ../../plugins/mfussenegger/nvim-dap
    ../../plugins/jbyuki/one-small-step-for-vimkind
    ../../plugins/leoluz/nvim-dap-go
    ../../plugins/mfussenegger/nvim-dap-python
    ../../plugins/theHamsta/nvim-dap-virtual-text
    ../../plugins/suketa/nvim-dap-ruby
    ../../plugins/rcarriga/nvim-dap-ui
  ];

  config =
    mkMerge [
      (mkIf cfg.enable
        {
          blackmatter.components.nvim.plugins =
            {
              ravenxrz."DAPInstall.nvim".enable = false;
              yriveiro."dap-go.nvim".enable = false;
              nvim-telescope."telescope-dap.nvim".enable = false;
              Pocco81."dap-buddy.nvim".enable = false;
              mfussenegger.nvim-dap.enable = false;
              jbyuki.one-small-step-for-vimkind.enable = false;
              leoluz.nvim-dap-go.enable = false;
              mfussenegger.nvim-dap-python.enable = false;
              theHamsta.nvim-dap-virtual-text.enable = false;
              suketa.nvim-dap-ruby.enable = false;
              rcarriga.nvim-dap-ui.enable = false;
            };
        }
      )
    ];
}
