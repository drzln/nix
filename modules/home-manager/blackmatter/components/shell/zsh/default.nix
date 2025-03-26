{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.zsh;
in let
  zsh-autosuggestions = pkgs.stdenv.mkDerivation {
    pname = "zsh-autosuggestions";
    version = "v0.7.0";

    src = pkgs.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-autosuggestions";
      rev = "v0.7.0";
      sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
    };

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
  zsh-syntax-highlighting = pkgs.stdenv.mkDerivation {
    pname = "zsh-syntax-highlighting";
    version = "0.8.0";

    src = pkgs.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-syntax-highlighting";
      rev = "0.8.0";
      sha256 = "sha256-ZhUEg0zIKv8GVHnLDBBsnxB93uEoXyPCO+uR4DWnEx4=";
    };

    installPhase = ''
      mkdir -p $out/share/zsh-syntax-highlighting
      make PREFIX=$out/share/zsh-syntax-highlighting install
      ln -s $out/share/zsh-syntax-highlighting/share/zsh-syntax-highlighting.zsh $out/zsh-syntax-highlighting.zsh
    '';
  };
in {
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
      home.packages = with pkgs; [
        cfg.package
        zoxide
        xsel
        bat
      ];

      programs.zoxide = {
        enable = true;
        enableZshIntegration = false;
      };

      home.file.".zshrc".text = ''
        # History
        HISTSIZE=10000000
        SAVEHIST=10000000
        HISTFILE=~/.zsh_history

        # Completion
        autoload -Uz compinit && compinit -i

        # Autosuggestions
        source ${zsh-autosuggestions}/zsh-autosuggestions.zsh

        # Syntax highlighting
        source ${zsh-syntax-highlighting}/zsh-syntax-highlighting.zsh

        # zoxide
        eval "$(zoxide init zsh)"

        # Aliases
        alias vim='nvim -u ~/.config/nvim/init.lua'
        alias vimdiff='nvim -d -u ~/.config/nvim/init.lua'
        alias cat='bat'
        alias cd='z'

        if [[ "$(uname)" == "Linux" ]]; then
          alias pbcopy='xsel --clipboard --input'
          alias pbpaste='xsel --clipboard --output'
        fi

        #direnv
        # turn off direnv messages
        export DIRENV_LOG_FORMAT=""
        eval "$(direnv hook zsh)"

        #fzf
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

        #starship
        export STARSHIP_CONFIG=~/.config/starship.toml
        eval "$(starship init zsh)"

        #xdg
        export XDG_DATA_HOME=$HOME/.local/share
        export XDG_CONFIG_HOME=$HOME/.config
        export XDG_STATE_HOME=$HOME/.local/state
      '';
    })
  ];
}
