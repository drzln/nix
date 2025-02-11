{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.tmux;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in {
  options = {
    blackmatter = {
      components = {
        shell.tmux.enable = mkEnableOption "shell.tmux";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs = {
        tmux =
          {
            enable = false;
            terminal = "xterm-kitty";
            aggressiveResize = false;
            baseIndex = 1;
            clock24 = false;
            customPaneNavigationAndResize = false;
            disableConfirmationPrompt = false;
            escapeTime = 1;
            historyLimit = 1000000;
            keyMode = "vi";
            newSession = false;
            shortcut = "f";
            reverseSplit = false;
            resizeAmount = 1;
            secureSocket = false;
            sensibleOnTop = false;
            tmuxinator = {
              enable = false;
            };
            tmuxp = {enable = false;};
          }
          // lib.optionalAttrs isLinux {
            extraConfig = builtins.readFile ./tmux-linux.conf;
            shell = "${pkgs.zsh}/bin/zsh";
          }
          // lib.optionalAttrs isDarwin {
            extraConfig = builtins.readFile ./tmux-darwin.conf;
            shell = "${pkgs.zsh}/bin/zsh";
          };
      };
    })
  ];
}
