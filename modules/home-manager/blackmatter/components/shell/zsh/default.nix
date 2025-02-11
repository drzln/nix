{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.blackmatter.components.shell.zsh;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in
{
  options = {
    blackmatter = {
      components = {
        shell.zsh.enable = mkEnableOption "shell.zsh";
        shell.zsh.package = mkOption {
          type = types.package;
          default = pkgs.zsh;
        };
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs;[ 
       cfg.package 
       zoxide
       xsel
       bat
      ];

      programs.zsh.shellAliases = {
        vim = "nvim -u ~/.config/nvim/init.lua";
        vimdiff = "nvim -d -u ~/.config/nvim/init.lua";
        cat = "bat";
        cd = "z";
      } // lib.optionalAttrs isLinux {
        pbcopy = "xsel --clipboard --input";
        pbpaste = "xsel --clipboard --output";
      };
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
      programs.zsh.syntaxHighlighting.enable = true;
      programs.zsh.prezto.enable = true;
      programs.zsh.enable = true;
      programs.zsh.history.size = 10000000;
      programs.zsh.history.save = 10000000;
      programs.zsh.autosuggestion.enable = true;
      programs.zsh.enableCompletion = true;
      programs.zsh.autocd = false;
      programs.zsh.zplug.enable = false;
      programs.zsh.initExtra = builtins.readFile ./zshrc.sh;
      home.file.".direnvrc".source = ./direnv/direnvrc.sh;
      xdg.configFile."shellz/direnv/main.sh".source = ./direnv/main.sh;
    })
  ];

}
